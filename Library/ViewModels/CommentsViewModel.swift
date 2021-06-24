import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

private let concurrentCommentLimit: UInt = 5

public protocol CommentsViewModelInputs {
  /// Call when the delegate method for the CommentCellDelegate is called.
  func commentCellDidTapReply(comment: Comment)

  /// Call when the delegate method for the CommentCellDelegate is called.
  func commentCellDidTapViewReplies(_ comment: Comment)

  /// Call when the User is posting a comment or reply.
  func commentComposerDidSubmitText(_ text: String)

  /// Call when the delegate method for the CommentRemovedCellDelegate is called.
  func commentRemovedCellDidTapURL(_ url: URL)

  /// Call when the user tapped to retry after failed pagination.
  func commentTableViewFooterViewDidTapRetry()

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

  /// Emits data to configure comment composer view.
  var configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never> { get }

  /// Configures the footer view with the current state.
  var configureFooterViewWithState: Signal<CommentTableViewFooterViewState, Never> { get }

  /// Emits the selected `Comment`, `Project` and a `Bool` to determine if keyboard should show when user to navigate to replies.
  var goToRepliesWithCommentProjectAndBecomeFirstResponder: Signal<(Comment, Project, Bool), Never> { get }

  /// Emits a list of `Comment`s and the `Project` to load into the data source.
  var loadCommentsAndProjectIntoDataSource: Signal<([Comment], Project), Never> { get }

  /// Emits a HelpType to use when presenting a HelpWebViewController.
  var showHelpWebViewController: Signal<HelpType, Never> { get }

  /// Emits when a comment has been posted and we should scroll to top and reset the composer.
  var resetCommentComposerAndScrollToTop: Signal<(), Never> { get }
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
      .combineLatest(initialProject, currentUser.signal, self.viewDidLoadProperty.signal.ignoreValues())
      .map { ($0.0, $0.1) }
      .map { project, currentUser in
        let isBacker = userIsBackingProject(project)
        let isCreatorOrCollaborator = !project.memberData.permissions.isEmpty && !isBacker
        let canPostComment = isBacker || isCreatorOrCollaborator

        guard let user = currentUser else {
          return (nil, false, true, false)
        }

        let url = URL(string: user.avatar.medium)
        return (url, canPostComment, false, false)
      }

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

    let currentComments = self.currentComments.signal.skipNil()

    let tappedToRetry = self.commentTableViewFooterViewDidTapRetryProperty.signal

    // Don't retry the first page if we've paged before.
    let retryFirstPage = tappedToRetry
      .take(until: isCloseToBottom)

    // Retry the next page if we've paged before at least once and tapped to retry.
    let retryNextPage = Signal.combineLatest(
      isCloseToBottom.take(first: 1),
      tappedToRetry
    )

    let requestNextPage = Signal.merge(
      isCloseToBottom.ignoreValues(),
      retryNextPage.ignoreValues()
    )

    let pullToRefresh = self.refreshProperty.signal

    let requestFirstPageWith = Signal.merge(
      projectOrUpdate,
      projectOrUpdate.takeWhen(retryFirstPage),
      projectOrUpdate.takeWhen(pullToRefresh)
        // Thread hop so that we can clear our comments buffer before newly paginated results.
        .ksr_debounce(.nanoseconds(0), on: AppEnvironment.current.scheduler)
    )

    let (comments, isLoading, _, errors) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPage,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.comments },
      cursorFromEnvelope: { ($0.slug, $0.cursor, $0.updateID) },
      requestFromParams: commentsFirstPage,
      requestFromCursor: commentsNextPage,
      // only return new pages, we'll concat them ourselves
      concater: { _, value in value }
    )

    let commentsWithRetryingComment = currentComments
      .takePairWhen(self.retryingComment.signal.skipNil())
      .map(unpack)
      .map(commentsReplacingCommentById)

    let commentsWithFailableOrComment = currentComments
      .takePairWhen(self.failableOrComment.signal.skipNil())
      .map(unpack)
      .map(commentsReplacingCommentById)

    self.resetCommentComposerAndScrollToTop = self.commentComposerDidSubmitTextProperty.signal.skipNil()
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

    let commentsAndProject = Signal.combineLatest(
      paginatedComments,
      initialProject
    )

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

    let commentCellTapped = self.didSelectCommentProperty.signal.skipNil()
    let erroredCommentTapped = commentCellTapped.filter { comment in comment.status == .failed }

    let viewCommentReplies = self.commentCellDidTapViewRepliesProperty.signal
      .skipNil()
      .filter { comment in comment.replyCount > 0 }

    let commentsWithRepliesAndProject = Signal.combineLatest(
      viewCommentReplies, initialProject
    )

    let replyCommentWithProject = Signal.combineLatest(
      self.commentCellDidTapReplyProperty.signal.skipNil(),
      initialProject
    )

    self.goToRepliesWithCommentProjectAndBecomeFirstResponder =
      Signal.merge(
        commentsWithRepliesAndProject.map { ($0, $1, false) },
        replyCommentWithProject.map { ($0, $1, true) }
      )

    let commentComposerDidSubmitText = self.commentComposerDidSubmitTextProperty.signal.skipNil()

    // get an id needed to post a comment to either a project or a project update
    let commentableId = projectOrUpdate
      .flatMap { projectOrUpdate in
        projectOrUpdate.ifLeft { project in
          SignalProducer.init(value: project.graphID)
        } ifRight: { update in
          SignalProducer.init(value: encodeToBase64("FreeformPost-\(update.id)"))
        }
      }

    let postFailableCommentConfigData:
      Signal<(project: Project, commentableId: String, user: User), Never> = Signal.combineLatest(
        initialProject,
        commentableId,
        currentUser.skipNil()
      ).map { project, commentableId, user in
        (project: project, commentableId: commentableId, user: user)
      }

    self.failableOrComment <~ postFailableCommentConfigData
      .takePairWhen(commentComposerDidSubmitText)
      .map { data in
        let ((project, commentableId, user), text) = data
        return (project, commentableId, user, text)
      }
      .flatMap(.concurrent(limit: concurrentCommentLimit), postCommentProducer)

    let currentlyRetrying = MutableProperty<Set<String>>([])

    let newErroredCommentTapped = erroredCommentTapped
      // Check that we are not currently retrying this comment.
      .filter { [currentlyRetrying] comment in !currentlyRetrying.value.contains(comment.id) }
      // If we pass the filter add it to our set of retrying comments.
      .on(value: { [currentlyRetrying] comment in
        currentlyRetrying.value.insert(comment.id)
      })

    self.retryingComment <~ commentableId
      .takePairWhen(newErroredCommentTapped)
      .map { commentableId, comment in
        (comment, commentableId)
      }
      .flatMap(.concurrent(limit: concurrentCommentLimit), retryCommentProducer)
      // Once we've emitted a value here the comment has been retried and can be removed.
      .on(value: { [currentlyRetrying] _, id in
        currentlyRetrying.value.remove(id)
      })

    let footerViewActivityState = Signal
      .combineLatest(isCloseToBottom, isLoading)
      .filter(second >>> isTrue)

    let initialLoadOrReload = Signal.merge(
      projectOrUpdate.ignoreValues(),
      self.loadCommentsAndProjectIntoDataSource.ignoreValues()
    )

    self.configureFooterViewWithState = Signal.merge(
      initialLoadOrReload.mapConst(.hidden),
      footerViewActivityState.mapConst(.activity),
      errors.mapConst(.error)
    )
    .skipRepeats()

    self.showHelpWebViewController = self.commentRemovedCellDidTapURLProperty.signal.skipNil()
      .map(HelpType.helpType)
      .skipNil()
  }

  // Properties to assist with injecting these values into the existing data streams.
  private let currentComments = MutableProperty<[Comment]?>(nil)
  private let retryingComment = MutableProperty<(Comment, String)?>(nil)
  private let failableOrComment = MutableProperty<(Comment, String)?>(nil)

  private let commentCellDidTapViewRepliesProperty = MutableProperty<Comment?>(nil)
  public func commentCellDidTapViewReplies(_ comment: Comment) {
    self.commentCellDidTapViewRepliesProperty.value = comment
  }

  private let didSelectCommentProperty = MutableProperty<Comment?>(nil)
  public func didSelectComment(_ comment: Comment) {
    self.didSelectCommentProperty.value = comment
  }

  fileprivate let commentComposerDidSubmitTextProperty = MutableProperty<String?>(nil)
  public func commentComposerDidSubmitText(_ text: String) {
    self.commentComposerDidSubmitTextProperty.value = text
  }

  fileprivate let commentRemovedCellDidTapURLProperty = MutableProperty<URL?>(nil)
  public func commentRemovedCellDidTapURL(_ url: URL) {
    self.commentRemovedCellDidTapURLProperty.value = url
  }

  fileprivate let commentCellDidTapReplyProperty = MutableProperty<Comment?>(nil)
  public func commentCellDidTapReply(comment: Comment) {
    self.commentCellDidTapReplyProperty.value = comment
  }

  private let commentTableViewFooterViewDidTapRetryProperty = MutableProperty(())
  public func commentTableViewFooterViewDidTapRetry() {
    self.commentTableViewFooterViewDidTapRetryProperty.value = ()
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
  public let configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never>
  public let configureFooterViewWithState: Signal<CommentTableViewFooterViewState, Never>
  public let goToRepliesWithCommentProjectAndBecomeFirstResponder: Signal<(Comment, Project, Bool), Never>
  public let loadCommentsAndProjectIntoDataSource: Signal<([Comment], Project), Never>
  public let showHelpWebViewController: Signal<HelpType, Never>
  public let resetCommentComposerAndScrollToTop: Signal<(), Never>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}

private func retryCommentProducer(
  erroredComment comment: Comment,
  commentableId: String
) -> SignalProducer<(Comment, String), Never> {
  // Retry posting the comment.
  AppEnvironment.current.apiService.postComment(
    input: .init(
      body: comment.body,
      commentableId: commentableId
    )
  )
  .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
  // Return a producer with the successful comment that is prefixed by a comment indicating that the
  // retry was successful and then, after a 3 second delay, the actual successful comment is returned.
  .flatMap { successfulComment -> SignalProducer<Comment, ErrorEnvelope> in
    let retrySuccessComment = successfulComment.updatingStatus(to: .retrySuccess)
      |> \.id .~ comment.id // Inject the original errored comment's ID to replace.

    return SignalProducer(value: successfulComment)
      .ksr_delay(.seconds(3), on: AppEnvironment.current.scheduler)
      .prefix(value: retrySuccessComment)
  }
  // Immediately return a comment in a retrying state when this producer starts.
  // Delay further emissions by 1 sec.
  .prefix(
    SignalProducer(value: comment.updatingStatus(to: .retrying))
      .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
      .prefix(value: comment.updatingStatus(to: .retrying))
  )
  // If retrying errors again, return the original comment returning it to its errored state.
  .demoteErrors(replaceErrorWith: comment)
  // Return the comment that will be replaced with the ID to find it by.
  .map { replacementComment in (replacementComment, comment.id) }
}

private func postCommentProducer(
  project: Project,
  commentableId: String,
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
      commentableId: commentableId
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

private func commentsFirstPage(from projectOrUpdate: Either<Project, Update>)
  -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
  return projectOrUpdate.ifLeft { project in
    AppEnvironment.current.apiService.fetchComments(
      query: commentsQuery(
        withProjectSlug:
        project.slug
      )
    )
  } ifRight: {
    AppEnvironment.current.apiService.fetchComments(
      query: projectUpdateCommentsQuery(id: $0.id.description)
    )
  }
}

private func commentsNextPage(
  from projectSlug: String?,
  cursor: String?,
  updateID: String?
) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
  if let projectSlug = projectSlug {
    return AppEnvironment.current.apiService.fetchComments(
      query: commentsQuery(
        withProjectSlug: projectSlug,
        after: cursor
      )
    )
  } else {
    guard let id = updateID else { return .empty }
    return AppEnvironment.current.apiService.fetchComments(
      query: projectUpdateCommentsQuery(
        id: id,
        after: cursor
      )
    )
  }
}
