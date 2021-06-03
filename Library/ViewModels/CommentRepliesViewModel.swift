import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentRepliesViewModelInputs {
  /// Call with the comment/project that we are viewing replies for. Both can be provided to minimize
  /// the number of API requests made, but it will be assumed we are viewing the replies for the comment.
  func configureWith(comment: Comment, project: Project)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentRepliesViewModelOutputs {
  // TODO: Likely we will be adding `[Comment]` to this output to load replies
  /// Emits a root `Comment`s and the `Project` to load into the data source.
  var loadCommentAndProjectIntoDataSource: Signal<(Comment, Project), Never> { get }
}

public protocol CommentRepliesViewModelType {
  var inputs: CommentRepliesViewModelInputs { get }
  var outputs: CommentRepliesViewModelOutputs { get }
}

public final class CommentRepliesViewModel: CommentRepliesViewModelType,
  CommentRepliesViewModelInputs,
  CommentRepliesViewModelOutputs {
  public init() {
    let rootCommentAndProject = Signal.combineLatest(
      self.commentAndProjectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.loadCommentAndProjectIntoDataSource = rootCommentAndProject
  }

  fileprivate let commentAndProjectProperty = MutableProperty<(Comment, Project)?>(nil)
  public func configureWith(comment: Comment, project: Project) {
    self.commentAndProjectProperty.value = (comment, project)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadCommentAndProjectIntoDataSource: Signal<(Comment, Project), Never>

  public var inputs: CommentRepliesViewModelInputs { return self }
  public var outputs: CommentRepliesViewModelOutputs { return self }
}
