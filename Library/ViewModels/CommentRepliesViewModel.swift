import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentRepliesViewModelInputs {
  /**
    Call with the comment and project that we are viewing replies for. `Comment` can be provided to minimize
    the number of API requests made (ie. no need to find the comment id), but this is for viewing the replies for the root comment.

     - parameter comment: The `Comment` we are viewing the replies.
     - parameter project: The `Project` the comment replies are for.
     - parameter update: The `Update?` the comment replies are for.
     - parameter inputAreaBecomeFirstResponder: A Bool that determines if the composer should become first responder.
     - parameter replyId: A `String?` that determines which cell to scroll to, if visible on the first page.
   **/
  func configureWith(comment: Comment, project: Project, update: Update?, inputAreaBecomeFirstResponder: Bool,
                     replyId: String?)

  /// Call when the User is posting a comment or reply.
  func commentComposerDidSubmitText(_ text: String)

  /// Call with a `Comment` when it is selected.
  func didSelectComment(_ comment: Comment)

  /// Call in `didSelectRow` when either a `ViewMoreRepliesCell` or `CommentViewMoreRepliesFailedCell` is tapped.
  func paginateOrErrorCellWasTapped()

  /// Call after the data source is loaded and the tableView reloads.
  func dataSourceLoaded()

  /// Call when there is a failure in requesting the first page of the data and the `CommentViewMoreRepliesFailedCell` is tapped.
  func retryFirstPage()

  /// Call when the view appears.
  func viewDidAppear()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentRepliesViewModelOutputs {
  /// Emits data to configure comment composer view.
  var configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never> { get }

  /// Emits a root `Comment`s  to load into the data source.
  var loadCommentIntoDataSource: Signal<Comment, Never> { get }

  /// Emits a tuple of (`Comment`,`Int`) and a `Project` to load into the data source
  var loadRepliesAndProjectIntoDataSource: Signal<(([Comment], Int), Project), Never> { get }

  /// Emits a `Comment`, `String` and `Project` to replace an optimistically posted comment after a network request completes.
  var loadFailableReplyIntoDataSource: Signal<(Comment, String, Project), Never> { get }

  /// Emits when a comment has been posted reset the composer.
  var resetCommentComposer: Signal<(), Never> { get }

  /// Emits when a replyId is supplied to the view controller configuration and we want to scroll to a specific index.
  var scrollToReply: Signal<String, Never> { get }

  /// Emits when a pagination error has occurred.
  var showPaginationErrorState: Signal<(), Never> { get }
}

public protocol CommentRepliesViewModelType {
  var inputs: CommentRepliesViewModelInputs { get }
  var outputs: CommentRepliesViewModelOutputs { get }
}

public final class CommentRepliesViewModel: CommentRepliesViewModelType,
  CommentRepliesViewModelInputs,
  CommentRepliesViewModelOutputs {
  public init() {
    let rootCommentProject = Signal.combineLatest(
      self.commentProjectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let rootComment = rootCommentProject.map(first)

    let project = rootCommentProject.map(second)

    self.loadCommentIntoDataSource = rootComment

    let currentUser = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.currentUser }

    let inputAreaBecomeFirstResponder = Signal.merge(
      rootCommentProject
        .map(third)
        .takeWhen(self.viewDidAppearProperty.signal),
      self.viewDidLoadProperty.signal.mapConst(false)
    ).skipRepeats()

    self.resetCommentComposer = self.commentComposerDidSubmitTextProperty.signal.skipNil()
      .ignoreValues()

    self.configureCommentComposerViewWithData = Signal
      .combineLatest(
        project,
        currentUser.signal,
        self.viewDidLoadProperty.signal,
        inputAreaBecomeFirstResponder
      )
      .map { ($0.0, $0.1, $0.3) }
      .map { project, currentUser, inputAreaBecomeFirstResponder in
        let isBacker = userIsBackingProject(project)
        let isCreatorOrCollaborator = !project.memberData.permissions.isEmpty && !isBacker
        let canPostComment = isBacker || isCreatorOrCollaborator

        guard let user = currentUser else {
          return (
            avatarURL: nil,
            canPostComment: false,
            hidden: true,
            becomeFirstResponder: false
          )
        }

        let url = URL(string: user.avatar.medium)
        return (url, canPostComment, false, inputAreaBecomeFirstResponder)
      }

    let commentCellTapped = self.didSelectCommentProperty.signal.skipNil()
    let erroredCommentTapped = commentCellTapped.filter { comment in comment.status == .failed }

    let requestFirstPageWith = Signal.merge(
      rootComment,
      rootComment.takeWhen(self.retryFirstPageProperty.signal)
    )

    let totalCountProperty = MutableProperty<Int>(0)

    // TODO: Handle isLoading from here
    let (replies, _, _, error) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: self.paginateOrErrorCellWasTappedProperty.signal,
      clearOnNewRequest: true,
      valuesFromEnvelope: { [totalCountProperty] envelope -> [Comment] in
        totalCountProperty.value = envelope.totalCount
        return envelope.replies
      },
      cursorFromEnvelope: { envelope in
        (envelope.comment, envelope.cursor)
      },
      requestFromParams: { comment in
        AppEnvironment.current.apiService
          .fetchCommentReplies(
            id: comment.id,
            cursor: nil,
            limit: CommentRepliesEnvelope.paginationLimit,
            withStoredCards: false
          )
      },
      requestFromCursor: { comment, cursor in
        AppEnvironment.current.apiService
          .fetchCommentReplies(
            id: comment.id,
            cursor: cursor,
            limit: CommentRepliesEnvelope.paginationLimit,
            withStoredCards: false
          )
      },
      // only return new pages, we'll concat them ourselves
      concater: { _, value in value }
    )

    let commentComposerDidSubmitText = self.commentComposerDidSubmitTextProperty.signal.skipNil()

    // If the Update is non-nil we send the FreeformPost format, otherwise we send the Project graphID
    let commentableId = self.updateProperty.signal.combineLatest(with: project)
      .map { update, project -> String in
        guard let update = update else {
          return project.graphID
        }
        return encodeToBase64("FreeformPost-\(update.id)")
      }

    let parentId = rootComment.flatMap { comment in
      SignalProducer.init(value: comment.id)
    }

    let failablePostReplyCommentConfigData:
      Signal<(project: Project, commentableId: String, parentId: String, user: User), Never> = Signal
      .combineLatest(
        project,
        commentableId,
        parentId,
        currentUser.skipNil()
      ).map { project, commentableId, parentId, user in
        (project, commentableId, parentId, user)
      }

    let failableCommentWithReplacementId = failablePostReplyCommentConfigData
      .takePairWhen(commentComposerDidSubmitText)
      .map { data in
        let ((project, commentableId, parentId, user), text) = data
        return (project, commentableId, parentId, user, text)
      }
      .flatMap(
        .concurrent(limit: CommentsViewModel.concurrentCommentLimit),
        CommentsViewModel.postCommentProducer
      )

    let currentlyRetrying = MutableProperty<Set<String>>([])

    let newErroredCommentTapped = erroredCommentTapped
      // Check that we are not currently retrying this comment.
      .filter { [currentlyRetrying] comment in !currentlyRetrying.value.contains(comment.id) }
      // If we pass the filter add it to our set of retrying comments.
      .on(value: { [currentlyRetrying] comment in
        currentlyRetrying.value.insert(comment.id)
      })

    let retryingComment = commentableId
      .takePairWhen(newErroredCommentTapped)
      .map { commentableId, comment in
        (comment, commentableId, comment.parentId)
      }
      .flatMap(
        .concurrent(limit: CommentsViewModel.concurrentCommentLimit),
        CommentsViewModel.retryCommentProducer
      )
      // Once we've emitted a value here the comment has been retried and can be removed.
      .on(value: { [currentlyRetrying] _, id in
        currentlyRetrying.value.remove(id)
      })

    self.loadRepliesAndProjectIntoDataSource = replies.withLatestFrom(totalCountProperty.signal)
      .combineLatest(with: project)

    let failableOrRetriedComment = Signal.merge(retryingComment, failableCommentWithReplacementId)

    self.loadFailableReplyIntoDataSource = Signal.combineLatest(failableOrRetriedComment, project)
      .map(unpack)

    self.showPaginationErrorState = error.ignoreValues()

    self.scrollToReply = self.replyIdProperty.signal
      .skipNil()
      .takeWhen(self.dataSourceLoadedProperty.signal)
  }

  private let didSelectCommentProperty = MutableProperty<Comment?>(nil)
  public func didSelectComment(_ comment: Comment) {
    self.didSelectCommentProperty.value = comment
  }

  fileprivate let commentComposerDidSubmitTextProperty = MutableProperty<String?>(nil)
  public func commentComposerDidSubmitText(_ text: String) {
    self.commentComposerDidSubmitTextProperty.value = text
  }

  fileprivate let commentProjectProperty = MutableProperty<(Comment, Project, Bool)?>(nil)
  fileprivate let updateProperty = MutableProperty<Update?>(nil)
  fileprivate let replyIdProperty = MutableProperty<String?>(nil)
  public func configureWith(
    comment: Comment,
    project: Project,
    update: Update?,
    inputAreaBecomeFirstResponder: Bool,
    replyId: String?
  ) {
    self.commentProjectProperty.value = (comment, project, inputAreaBecomeFirstResponder)
    self.updateProperty.value = update
    self.replyIdProperty.value = replyId
  }

  fileprivate let paginateOrErrorCellWasTappedProperty = MutableProperty(())
  public func paginateOrErrorCellWasTapped() {
    self.paginateOrErrorCellWasTappedProperty.value = ()
  }

  fileprivate let retryFirstPageProperty = MutableProperty(())
  public func retryFirstPage() {
    self.retryFirstPageProperty.value = ()
  }

  fileprivate let dataSourceLoadedProperty = MutableProperty(())
  public func dataSourceLoaded() {
    self.dataSourceLoadedProperty.value = ()
  }

  fileprivate let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never>
  public let loadCommentIntoDataSource: Signal<Comment, Never>
  public var loadRepliesAndProjectIntoDataSource: Signal<(([Comment], Int), Project), Never>
  public let loadFailableReplyIntoDataSource: Signal<(Comment, String, Project), Never>
  public let resetCommentComposer: Signal<(), Never>
  public let scrollToReply: Signal<String, Never>
  public let showPaginationErrorState: Signal<(), Never>

  public var inputs: CommentRepliesViewModelInputs { return self }
  public var outputs: CommentRepliesViewModelOutputs { return self }
}
