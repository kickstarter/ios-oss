import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentRepliesViewModelInputs {
  /// Call with the comment and project that we are viewing replies for. `Comment` can be provided to minimize
  /// the number of API requests made (ie. no need to find the comment id), but this is for viewing the replies for the root comment.
  func configureWith(comment: Comment, project: Project)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentRepliesViewModelOutputs {
  /// Emits data to configure comment composer view.
  var configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never> { get }
  
  // TODO: Create a new output for `[Comment]` to only return replies and tie it directly to `loadReplies(comments: [Comment])` in the `CommentRepliesDataSource`. Removes dependency on the root comment to the network request that gets replies.
  /// Emits a root `Comment`s  to load into the data source.
  var loadCommentIntoDataSource: Signal<Comment, Never> { get }
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
    
    self.configureCommentComposerViewWithData = Signal
      .combineLatest(project, currentUser.signal, self.viewDidLoadProperty.signal.ignoreValues())
      .map { ($0.0, $0.1) }
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
  }

  fileprivate let commentProjectProperty = MutableProperty<(Comment, Project)?>(nil)
  public func configureWith(comment: Comment, project: Project) {
    self.commentProjectProperty.value = (comment, project)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configureCommentComposerViewWithData: Signal<CommentComposerViewData, Never>
  public let loadCommentIntoDataSource: Signal<Comment, Never>

  public var inputs: CommentRepliesViewModelInputs { return self }
  public var outputs: CommentRepliesViewModelOutputs { return self }
}
