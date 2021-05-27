import KsApi
import Prelude
import ReactiveSwift

public protocol CommentCellViewModelInputs {
  /// Call when bindStyles is called.
  func bindStyles()

  /// Call to configure with a Comment and User.
  func configureWith(comment: Comment, user: User?)
}

public protocol CommentCellViewModelOutputs {
  /// Emits author's badge for a comment.
  var authorBadge: Signal<Comment.AuthorBadge, Never> { get }

  /// Emits text containing author's fullname or username.
  var authorName: Signal<String, Never> { get }

  /// Emits a url to the comment author's image.
  var authorImageURL: Signal<URL, Never> { get }

  /// Emits text containing comment body.
  var body: Signal<String, Never> { get }

  /// Emits text  relative time the comment was posted.
  var postTime: Signal<String, Never> { get }

  /// Emits whether or not the view replies container is hidden.
  var viewRepliesContainerHidden: Signal<Bool, Never> { get }
}

public protocol CommentCellViewModelType {
  var inputs: CommentCellViewModelInputs { get }
  var outputs: CommentCellViewModelOutputs { get }
}

public final class CommentCellViewModel:
  CommentCellViewModelType, CommentCellViewModelInputs, CommentCellViewModelOutputs {
  public init() {
    let comment = self.commentUser.signal.skipNil()
      .map { comment, _ in comment }

    self.authorImageURL = comment
      .map(\.author.imageUrl)
      .map(URL.init)
      .skipNil()

    self.body = comment.map(\.body)

    self.authorName = comment.map(\.author.name)

    self.postTime = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .medium, timeStyle: .short)
    }

    let badge = self.commentUser.signal.skipNil()
      .map { comment, user in
        comment.author.id == user?.id.description ? .you : comment.authorBadge
      }

    self.authorBadge = Signal.merge(
      badge,
      badge.takeWhen(self.bindStylesProperty.signal)
    )

    self.viewRepliesContainerHidden = comment.map(\.replyCount)
      .map { $0 == 0 }
  }

  private var bindStylesProperty = MutableProperty(())
  public func bindStyles() {
    self.bindStylesProperty.value = ()
  }

  fileprivate let commentUser = MutableProperty<(Comment, User?)?>(nil)
  public func configureWith(comment: Comment, user: User?) {
    self.commentUser.value = (comment, user)
  }

  public let authorBadge: Signal<Comment.AuthorBadge, Never>
  public var authorImageURL: Signal<URL, Never>
  public let body: Signal<String, Never>
  public let authorName: Signal<String, Never>
  public let postTime: Signal<String, Never>
  public let viewRepliesContainerHidden: Signal<Bool, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}
