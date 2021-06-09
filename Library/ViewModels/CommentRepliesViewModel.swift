import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol CommentRepliesViewModelInputs {
  /// Call with the comment that we are viewing replies for. `Comment` can be provided to minimize
  /// the number of API requests made (ie. no need to find the comment id), but this is for viewing the replies for the root comment.
  func configureWith(comment: Comment)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CommentRepliesViewModelOutputs {
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
    let rootComment = Signal.combineLatest(
      self.commentProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.loadCommentIntoDataSource = rootComment
  }

  fileprivate let commentProperty = MutableProperty<(Comment)?>(nil)
  public func configureWith(comment: Comment) {
    self.commentProperty.value = comment
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadCommentIntoDataSource: Signal<Comment, Never>

  public var inputs: CommentRepliesViewModelInputs { return self }
  public var outputs: CommentRepliesViewModelOutputs { return self }
}
