import KsApi
import Prelude
import ReactiveSwift

public protocol CommentCellViewModelInputs {
  /// Call to configure with a Comment.
  func configureWith(comment: DemoComment)
}

public protocol CommentCellViewModelOutputs {
  /// Emits a url to the comment author's image.
  var avatarImageURL: Signal<URL?, Never> { get }

  /// Emits text containing comment body
  var body: Signal<String, Never> { get }

  /// Emits text containing author's fullname or username
  var authorName: Signal<String, Never> { get }

  /// Emits text  relative time the comment was posted
  var postTime: Signal<String, Never> { get }

  /// Emits author's tag for a comment
  var userTag: Signal<DemoComment.UserTagEnum, Never> { get }
}

public protocol CommentCellViewModelType {
  var inputs: CommentCellViewModelInputs { get }
  var outputs: CommentCellViewModelOutputs { get }
}

public final class CommentCellViewModel:
  CommentCellViewModelType, CommentCellViewModelInputs, CommentCellViewModelOutputs {
  public init() {
    let comment = self.commentProperty.signal.skipNil()

    self.avatarImageURL = comment
      .map { $0.imageURL }.map(URL.init)

    self.body = comment.map { $0.body }

    self.authorName = comment.map { $0.authorName }

    self.postTime = comment.map { $0.postTime }

    self.userTag = comment.map { $0.userTag }
  }

  fileprivate let commentProperty = MutableProperty<DemoComment?>(nil)
  public func configureWith(comment: DemoComment) {
    self.commentProperty.value = comment
  }

  public let avatarImageURL: Signal<URL?, Never>
  public let body: Signal<String, Never>
  public let authorName: Signal<String, Never>
  public let postTime: Signal<String, Never>
  public let userTag: Signal<DemoComment.UserTagEnum, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}
