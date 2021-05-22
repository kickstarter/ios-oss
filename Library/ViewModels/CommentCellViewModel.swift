import KsApi
import Prelude
import ReactiveSwift

public protocol CommentCellViewModelInputs {
  /// Call to configure with a Comment and User.
  func configureWith(comment: Comment, viewer: User?)
}

public protocol CommentCellViewModelOutputs {
  /// Emits author's tag for a comment
  var authorBadge: Signal<Comment.AuthorBadge, Never> { get }

  /// Emits text containing author's fullname or username
  var authorName: Signal<String, Never> { get }

  /// Emits a url to the comment author's image.
  var avatarImageURL: Signal<URL?, Never> { get }

  /// Emits text containing comment body
  var body: Signal<String, Never> { get }

  /// Emits text  relative time the comment was posted
  var postTime: Signal<String, Never> { get }
}

public protocol CommentCellViewModelType {
  var inputs: CommentCellViewModelInputs { get }
  var outputs: CommentCellViewModelOutputs { get }
}

public final class CommentCellViewModel:
  CommentCellViewModelType, CommentCellViewModelInputs, CommentCellViewModelOutputs {
  public init() {
    let comment = self.commentViewer.signal.skipNil()
      .map { comment, _ in comment }

    self.avatarImageURL = comment
      .map { $0.author.imageUrl }.map(URL.init)

    self.body = comment.map(\.body)

    self.authorName = comment.map(\.author.name)

    self.postTime = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .medium, timeStyle: .short)
    }

    self.authorBadge = self.commentViewer.signal.skipNil()
      .map { comment, viewer in
        comment.author.id == viewer?.id.description ? .you : comment.authorBadge
      }
  }

  fileprivate let commentViewer = MutableProperty<(Comment, User?)?>(nil)
  public func configureWith(comment: Comment, viewer: User?) {
    self.commentViewer.value = (comment, viewer)
  }

  public let authorBadge: Signal<Comment.AuthorBadge, Never>
  public let avatarImageURL: Signal<URL?, Never>
  public let body: Signal<String, Never>
  public let authorName: Signal<String, Never>
  public let postTime: Signal<String, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}
