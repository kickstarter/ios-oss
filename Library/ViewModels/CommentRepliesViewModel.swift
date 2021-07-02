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
     - parameter inputAreaBecomeFirstResponder: A Bool that determines if the composer should become first responder.
   **/
  func configureWith(comment: Comment, project: Project, inputAreaBecomeFirstResponder: Bool)

  /// Call when a `ViewMoreRepliesCell` on the `CommentRepliesViewController` is selected.
  func viewMoreRepliesCellWasTapped()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentRepliesViewModelOutputs {
  /// Emits data to configure comment composer view.
  var configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never> { get }

  /// Emits a root `Comment`s  to load into the data source.
  var loadCommentIntoDataSource: Signal<Comment, Never> { get }

  /// Emits a list of `Replies` and `Project` to load into the data source
  var loadRepliesAndProjectIntoDataSource: Signal<(([Comment], Int), Project), Never> { get }
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

    /**
     FIXME: There's currently an issue raised here: https://github.com/kickstarter/ios-oss/pull/1523#discussion_r655679914 where
     `project.memberData.permissions` is not covered in this logic, as it also controls the reply button show/hide.
      This has been logged in this ticket https://kickstarter.atlassian.net/browse/NT-2034.
     */
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

    let totalCountProperty = MutableProperty<Int>(0)

    // TODO: Handle isLoading from here
    let (replies, _, _, _) = paginate(
      requestFirstPageWith: rootComment,
      requestNextPageWhen: self.viewMoreRepliesCellWasTappedProperty.signal,
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
          .fetchCommentReplies(query: commentRepliesQuery(withCommentId: comment.id))
      },
      requestFromCursor: {
        AppEnvironment.current.apiService
          .fetchCommentReplies(query: commentRepliesQuery(withCommentId: $0.0.id, before: $0.1))
      },
      // only return new pages, we'll concat them ourselves
      concater: { _, value in value }
    )

    let repliesAndTotalCount = replies.on(value: { print($0.count) })
      .withLatestFrom(totalCountProperty.signal)

    self.loadRepliesAndProjectIntoDataSource = Signal.combineLatest(repliesAndTotalCount, project)
  }

  fileprivate let commentProjectProperty = MutableProperty<(Comment, Project, Bool)?>(nil)
  public func configureWith(comment: Comment, project: Project, inputAreaBecomeFirstResponder: Bool) {
    self.commentProjectProperty.value = (comment, project, inputAreaBecomeFirstResponder)
  }

  fileprivate let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewMoreRepliesCellWasTappedProperty = MutableProperty(())
  public func viewMoreRepliesCellWasTapped() {
    self.viewMoreRepliesCellWasTappedProperty.value = ()
  }

  public let configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never>
  public let loadCommentIntoDataSource: Signal<Comment, Never>
  public var loadRepliesAndProjectIntoDataSource: Signal<(([Comment], Int), Project), Never>

  public var inputs: CommentRepliesViewModelInputs { return self }
  public var outputs: CommentRepliesViewModelOutputs { return self }
}
