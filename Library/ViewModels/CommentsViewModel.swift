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
  /// Emits a boolean that determines if the comment input area is visible.
  var commentComposerViewHidden: Signal<Bool, Never> { get }

  /// Emits data to configure comment composer view.
  var configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never> { get }

  // Emits a message if there is an error from posting a comment.
  var errorMessage: Signal<String, Never> { get }

  /// Emits the selected `Comment` and `Project` to navigate to its replies.
  var goToCommentReplies: Signal<(Comment, Project), Never> { get }

  /// Emits a boolean that determines if comments are currently loading.
  var isCommentsLoading: Signal<Bool, Never> { get }

  /// Emits a list of `Comment`s and the `Project` to load into the data source.
  var loadCommentsAndProjectIntoDataSource: Signal<([Comment], Project), Never> { get }

  /// Emits when a comment was successfully posted.
  var postCommentSuccessful: Signal<Comment, Never> { get }

  /// Emits when a comment was submitted to be posted.
  var postCommentSubmitted: Signal<(), Never> { get }
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

        guard let user = currentUser else {
          return (nil, isBacker)
        }

        let url = URL(string: user.avatar.medium)
        return (url, isBacker)
      }

    self.commentComposerViewHidden = currentUser.signal
      .map { user in user.isNil }

    let postCommentEvent = initialProject
      .takePairWhen(self.postCommentButtonTappedProperty.signal.skipNil())
      .switchMap { project, comment in
        AppEnvironment.current.apiService
          .postComment(input: .init(
            body: comment,
            commentableId: project.graphID
          ))
          .materialize()
      }

    // TODO: Handle error and success states appropriately for the datasource item
    self.postCommentSuccessful = postCommentEvent.values().map { $0 }
    self.errorMessage = postCommentEvent.errors().map { $0.errorMessages.first }.skipNil()

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let requestFirstPageWith = Signal.merge(
      initialProject,
      initialProject.takeWhen(self.refreshProperty.signal),
      initialProject.takeWhen(self.postCommentSuccessful)
    )

    let (comments, isLoading, _, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.comments },
      cursorFromEnvelope: { ($0.slug, $0.cursor) },
      requestFromParams: { project in
        AppEnvironment.current.apiService
          .fetchComments(query: commentsQuery(withProjectSlug: project.slug))
      },
      requestFromCursor: { projectSlug, cursor in
        AppEnvironment.current.apiService
          .fetchComments(query: commentsQuery(
            withProjectSlug: projectSlug,
            after: cursor
          ))
      }
    )

    let optimisticPostComment = Signal.combineLatest(
      initialProject,
      currentUser.skipNil()
    ).takePairWhen(self.postCommentButtonTappedProperty.signal.skipNil())
      .map(unpack)
      .map(Comment.createFailableComment)

    self.postCommentSubmitted = optimisticPostComment.ignoreValues()

    let commentsWithOptimisticPostComment = Signal
      .combineLatest(comments, optimisticPostComment)
      .map { loadedComments, optimisticComment -> [Comment] in
        [optimisticComment] + loadedComments
      }.map { $0 as Array }

    let commentsAndProject = Signal.combineLatest(
      Signal.merge(comments, commentsWithOptimisticPostComment),
      initialProject
    )

    self.loadCommentsAndProjectIntoDataSource = commentsAndProject
    self.isCommentsLoading = isLoading

    self.goToCommentReplies = self.didSelectCommentProperty.signal.skipNil()
      .filter { comment in
        [comment.replyCount > 0, comment.status == .success].allSatisfy(isTrue)
      }
      .withLatestFrom(initialProject)
  }

  private let didSelectCommentProperty = MutableProperty<Comment?>(nil)
  public func didSelectComment(_ comment: Comment) {
    self.didSelectCommentProperty.value = comment
  }

  fileprivate let postCommentButtonTappedProperty = MutableProperty<String?>(nil)
  public func commentComposerDidSubmitText(_ text: String) {
    self.postCommentButtonTappedProperty.value = text
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

  public let commentComposerViewHidden: Signal<Bool, Never>
  public let configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never>
  public let errorMessage: Signal<String, Never>
  public let goToCommentReplies: Signal<(Comment, Project), Never>
  public let isCommentsLoading: Signal<Bool, Never>
  public let loadCommentsAndProjectIntoDataSource: Signal<([Comment], Project), Never>
  public let postCommentSuccessful: Signal<Comment, Never>
  public var postCommentSubmitted: Signal<(), Never>

  public var inputs: CommentsViewModelInputs { return self }
  public var outputs: CommentsViewModelOutputs { return self }
}
