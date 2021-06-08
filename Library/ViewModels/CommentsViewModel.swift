import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentsViewModelInputs {
  /// Call when the User is posting a comment or reply
  func commentComposerDidSubmitText(_ text: String)

  /// Call with the project/update that we are viewing comments for. Both can be provided to minimize
  /// the number of API requests made, but it will be assumed we are viewing the comments for the update.
  func configureWith(project: Project?, update: Update?)

  /// Call with a `Comment` when it is selected.
  func didSelectComment(_ comment: Comment)

  ///  Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol CommentsViewModelOutputs {
  /// Emits a boolean that determines if comments are currently loading.
  var beginOrEndRefreshing: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if cell separator is to be hidden.
  var cellSeparatorHidden: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the comment input area is visible.
  var commentComposerViewHidden: Signal<Bool, Never> { get }

  /// Emits data to configure comment composer view.
  var configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never> { get }

  /// Emits the selected `Comment` and `Project` to navigate to its replies.
  var goToCommentReplies: Signal<(Comment, Project), Never> { get }

  /// Emits a list of `Comment`s and the `Project` to load into the data source.
  var loadCommentsAndProjectIntoDataSource: Signal<([Comment], Project), Never> { get }

  /// Emits when a comment has been posted and we should scroll to top and reset the composer.
  var resetCommentComposerAndScrollToTop: Signal<(), Never> { get }

  /// Emits a Bool that determines if the activity indicator should render.
  var showLoadingIndicatorInFooterView: Signal<Bool, Never> { get }
}

public protocol CommentsViewModelType {
  var inputs: CommentsViewModelInputs { get }
  var outputs: CommentsViewModelOutputs { get }
}

public final class CommentsViewModel: CommentsViewModelType,
  CommentsViewModelInputs,
  CommentsViewModelOutputs {
  public init() {
    let projectOrUpdate = Signal.combineLatest(
      self.projectAndUpdateProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .flatMap { project, update in
      SignalProducer(value: project.map(Either.left) ?? update.map(Either.right))
        .skipNil()
    }

    let currentUser = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.currentUser }

    let initialProject = projectOrUpdate
      .flatMap { projectOrUpdate in
        projectOrUpdate.ifLeft(
          SignalProducer.init(value:),
          ifRight: {
            AppEnvironment.current.apiService.fetchProject(param: .id($0.projectId)).demoteErrors()
          }
        )
      }

    self.configureCommentComposerViewWithData = Signal
      .combineLatest(initialProject.signal, currentUser.signal)
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { project, currentUser in
        let isBacker = userIsBackingProject(project)
        let isCreatorOrCollaborator = !project.memberData.permissions.isEmpty && !isBacker
        let canPostComment = isBacker || isCreatorOrCollaborator

        guard let user = currentUser else {
          return (nil, false)
        }

        let url = URL(string: user.avatar.medium)
        return (url, canPostComment)
      }

    self.commentComposerViewHidden = currentUser.signal
      .map { user in user.isNil }

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total -> Bool in
        // TODO: ensure this does not page when cells are less than threshold.
        // Prevent paging when only the empty state cell is shown.
        guard total > 1 else { return false }
        return row >= total - 3
      }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let pullToRefresh = self.refreshProperty.signal

    let requestFirstPageWith = Signal.merge(
      initialProject,
      initialProject.takeWhen(pullToRefresh)
        // Thread hop so that we can clear our comments buffer before newly paginated results.
        .ksr_debounce(.nanoseconds(0), on: AppEnvironment.current.scheduler)
    )

    let (comments, isLoading, _, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.comments },
      cursorFromEnvelope: { ($0.slug, $0.cursor) },
      requestFromParams: { project in
        AppEnvironment.current.apiService.fetchComments(
          query: commentsQuery(withProjectSlug: project.slug)
        )
      },
      requestFromCursor: { projectSlug, cursor in
        AppEnvironment.current.apiService.fetchComments(
          query: commentsQuery(
            withProjectSlug: projectSlug,
            after: cursor
          )
        )
      },
      // only return new pages, we'll concat them ourselves
      concater: { _, value in value }
    )

    let currentComments = self.currentComments.signal.skipNil()

    let commentsWithRetryingComment = currentComments
      .takePairWhen(self.retryingComment.signal.skipNil())
      .map(unpack)
      .map(commentsReplacingCommentById)

    let commentsWithFailableOrComment = currentComments
      .takePairWhen(self.failableOrComment.signal.skipNil())
      .map(unpack)
      .map(commentsReplacingCommentById)

    self.resetCommentComposerAndScrollToTop = commentsWithFailableOrComment
      // We only want to scroll to top for failable comments as they represent the initial
      // comment that's inserted. We check here to see that the first comment's ID is a UUID
      // to determine this. There may be better ways.
      .map { UUID(uuidString: $0.first?.id ?? "") }
      .filter(isNotNil)
      .ignoreValues()

    let paginatedComments = Signal.merge(
      // Pull to refresh, clear comments cache.
      pullToRefresh.mapConst(([], true)),
      // Regular paged comments, don't clear accumulator.
      comments.map { comments in (comments, false) },
      // Comments with a retrying comment, replace our current comments cache with this.
      commentsWithRetryingComment.map { comments in (comments, true) },
      // Comments with a failable or new comment, replace our current comments cache with this.
      commentsWithFailableOrComment.map { comments in (comments, true) }
    )
    .scan([]) { accum, value -> [Comment] in
      let (comments, clear) = value
      guard clear == false else { return comments }
      return accum + comments
    }

    let commentsAndProject = initialProject
      .takePairWhen(paginatedComments)
      .map { ($1, $0) }

    self.currentComments <~ commentsAndProject.map(first)
      // Thread hop so that we don't circularly buffer.
      .ksr_debounce(.nanoseconds(0), on: AppEnvironment.current.scheduler)

    self.loadCommentsAndProjectIntoDataSource = Signal.merge(
      // If we start off with no comments, show an empty state.
      commentsAndProject.take(first: 1),
      // Subsequent empty emissions (pull to refresh) should be ignored until replaced.
      commentsAndProject.skip(first: 1).filter { comments, _ in comments.isEmpty == false }
    )
    self.beginOrEndRefreshing = isLoading
    self.cellSeparatorHidden = commentsAndProject.map(first).map { $0.count == .zero }

    let commentTapped = self.didSelectCommentProperty.signal.skipNil()
    let regularCommentTapped = commentTapped.filter { comment in
      [comment.status == .success, comment.isDeleted == false].allSatisfy(isTrue)
    }
    let erroredCommentTapped = commentTapped.filter { comment in comment.status == .failed }

    self.goToCommentReplies = regularCommentTapped
      .filter { comment in comment.replyCount > 0 }
      .withLatestFrom(initialProject)

    let commentComposerDidSubmitText = self.commentComposerDidSubmitTextProperty.signal.skipNil()

    self.failableOrComment <~ Signal.combineLatest(
      initialProject,
      currentUser.skipNil()
    )
    .takePairWhen(commentComposerDidSubmitText)
    .map(unpack)
    .flatMap(postCommentProducer)

    self.retryingComment <~ initialProject
      .takePairWhen(erroredCommentTapped)
      .map { ($1, $0) }
      .flatMap(retryCommentProducer)

    self.showLoadingIndicatorInFooterView = Signal
      .combineLatest(isCloseToBottom, self.beginOrEndRefreshing)
      .map(second >>> isTrue)
  }

  // Properties to assist with injecting these values into the existing data streams.
  private let currentComments = MutableProperty<[Comment]?>(nil)
  private let retryingComment = MutableProperty<(Comment, String)?>(nil)
  private let failableOrComment = MutableProperty<(Comment, String)?>(nil)

  private let didSelectCommentProperty = MutableProperty<Comment?>(nil)
  public func didSelectComment(_ comment: Comment) {
    self.didSelectCommentProperty.value = comment
  }

  fileprivate let commentComposerDidSubmitTextProperty = MutableProperty<String?>(nil)
  public func commentComposerDidSubmitText(_ text: String) {
    self.commentComposerDidSubmitTextProperty.value = text
  }

  fileprivate let projectAndUpdateProperty = MutableProperty<(Project?, Update?)?>(nil)
  public func configureWith(project: Project?, update: Update?) {
    self.projectAndUpdateProperty.value = (project, update)
  }

  fileprivate let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let beginOrEndRefreshing: Signal<Bool, Never>
  public let cellSeparatorHidden: Signal<Bool, Never>
  public let commentComposerViewHidden: Signal<Bool, Never>
  public let configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never>
  public let goToCommentReplies: Signal<(Comment, Project), Never>
  public let loadCommentsAndProjectIntoDataSource: Signal<([Comment], Project), Never>
  public let resetCommentComposerAndScrollToTop: Signal<(), Never>
  public let showLoadingIndicatorInFooterView: Signal<Bool, Never>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}

private func retryCommentProducer(
  erroredComment comment: Comment,
  project: Project
) -> SignalProducer<(Comment, String), Never> {
  // Retry posting the comment.
  AppEnvironment.current.apiService.postComment(
    input: .init(
      body: comment.body,
      commentableId: project.graphID
    )
  )
  .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
  // Return a producer with the successful comment that is prefixed by a comment indicating that the
  // retry was successful and then, after a 1 second delay, the actual successful comment is returned.
  .flatMap { successfulComment -> SignalProducer<Comment, ErrorEnvelope> in
    let retrySuccessComment = successfulComment.updatingStatus(to: .retrySuccess)
      |> \.id .~ comment.id // Inject the original errored comment's ID to replace.

    return SignalProducer(value: successfulComment)
      .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
      .prefix(value: retrySuccessComment)
  }
  // Immediately return a comment in a retrying state when this producer starts.
  .prefix(value: comment.updatingStatus(to: .retrying))
  // If retrying errors again, return the original comment returning it to its errored state.
  .demoteErrors(replaceErrorWith: comment)
  // Return the comment that will be replaced with the ID to find it by.
  .map { replacementComment in (replacementComment, comment.id) }
}

private func postCommentProducer(
  project: Project,
  user: User,
  body: String
) -> SignalProducer<(Comment, String), Never> {
  let failableComment = Comment.failableComment(
    withId: AppEnvironment.current.uuidType.init().uuidString,
    date: AppEnvironment.current.dateType.init().date,
    project: project,
    user: user,
    body: body
  )

  // Post the new comment.
  return AppEnvironment.current.apiService.postComment(
    input: .init(
      body: body,
      commentableId: project.graphID
    )
  )
  .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
  // Immediately return a failable comment with a generated ID.
  .prefix(value: failableComment)
  // If the request errors we return the failableComment in a failed state.
  .demoteErrors(replaceErrorWith: failableComment.updatingStatus(to: .failed))
  // Once the request completes return the actual comment and replace it by its ID.
  .map { commentOrFailable in (commentOrFailable, failableComment.id) }
}

private func commentsReplacingCommentById(
  _ comments: [Comment],
  replacingComment: Comment,
  withId id: String
) -> [Comment] {
  // TODO: We may need to introduce optimizations here if this becomes problematic for projects that have
  /// thousands of comments. Consider an accompanying `Set` to track membership or replacing entirely
  /// with an `OrderedSet`.
  guard let commentIndex = comments.firstIndex(where: { $0.id == id }) else {
    // If the comment we're replacing is not found, it's new, prepend it.
    return [replacingComment] + comments
  }

  var mutableComments = comments
  mutableComments[commentIndex] = replacingComment

  return mutableComments
}
