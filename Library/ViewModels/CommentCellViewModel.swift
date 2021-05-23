import KsApi
import Prelude
import ReactiveSwift

public protocol CommentCellViewModelInputs {
  /// Call to configure with a Comment and User.
  func configureWith(comment: Comment, viewer: User?)
}

public protocol CommentCellViewModelOutputs {
  /// Emits a styling for the author's badge and an alignment for the stackview containing `authorName` and `authorBadge`
  var authorBadgeStyleStackViewAligment: Signal<(PaddingLabelStyle, UIStackView.Alignment), Never> { get }

  /// Emits text containing author's fullname or username
  var authorName: Signal<String, Never> { get }

  /// Emits a url to the comment author's image and a placeholder image.
  var authorImageURLAndPlaceholderImageName: Signal<(URL, String), Never> { get }

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

    self.authorBadgeStyleStackViewAligment = self.commentViewer.signal.skipNil()
      .map { comment, viewer in
        comment.author.id == viewer?.id.description ? .you : comment.authorBadge
      }
      .map(setAuthorBadgeStyleStackViewAligment)

    self.authorImageURLAndPlaceholderImageName = comment
      .map(\.author.imageUrl)
      .map(URL.init)
      .skipNil()
      .map { ($0, "avatar--placeholder") }

    self.body = comment.map(\.body)

    self.authorName = comment.map(\.author.name)

    self.postTime = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .medium, timeStyle: .short)
    }
  }

  fileprivate let commentViewer = MutableProperty<(Comment, User?)?>(nil)
  public func configureWith(comment: Comment, viewer: User?) {
    self.commentViewer.value = (comment, viewer)
  }

  public let authorBadgeStyleStackViewAligment: Signal<(PaddingLabelStyle, UIStackView.Alignment), Never>
  public var authorImageURLAndPlaceholderImageName: Signal<(URL, String), Never>
  public let body: Signal<String, Never>
  public let authorName: Signal<String, Never>
  public let postTime: Signal<String, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}

private func setAuthorBadgeStyleStackViewAligment(
  from badge: Comment.AuthorBadge
) -> (PaddingLabelStyle, UIStackView.Alignment) {
  switch badge {
  case .creator:
    return (creatorAuthorBadgeStyle, .center)
  case .superbacker:
    return (superbackerAuthorBadgeStyle, .top)
  case .you:
    return (youAuthorBadgeStyle, .center)
  default:
    return (defaultAuthorBadgeStyle, .center)
  }
}
