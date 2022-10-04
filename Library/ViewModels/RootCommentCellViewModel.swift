import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol RootCommentCellViewModelInputs {
  /// Call when bindStyles is called.
  func bindStyles()

  /// Call to configure with a Comment
  func configureWith(comment: Comment)
}

public protocol RootCommentCellViewModelOutputs {
  /// Emits author's badge for a comment.
  var authorBadge: Signal<Comment.AuthorBadge, Never> { get }

  /// Emits a url to the comment author's image.
  var authorImageURL: Signal<URL, Never> { get }

  /// Emits text containing author's fullname or username.
  var authorName: Signal<String, Never> { get }

  /// Emits text containing comment body.
  var body: Signal<String, Never> { get }

  /// Emits text  relative time the comment was posted.
  var postTime: Signal<String, Never> { get }
}

public protocol RootCommentCellViewModelType {
  var inputs: RootCommentCellViewModelInputs { get }
  var outputs: RootCommentCellViewModelOutputs { get }
}

public final class RootCommentCellViewModel:
  RootCommentCellViewModelType, RootCommentCellViewModelInputs, RootCommentCellViewModelOutputs {
  public init() {
    let comment = self.comment.signal.skipNil()

    self.authorImageURL = comment
      .map(\.author.imageUrl)
      .map(URL.init)
      .skipNil()

    self.body = comment.map(\.body)

    self.authorName = comment.map(\.author.name)

    self.postTime = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .medium, timeStyle: .short)
    }

    let badge = self.comment.signal
      .skipNil()
      .map { comment in
        comment.author.id == AppEnvironment.current.currentUser?.id.description ? .you : comment.authorBadge
      }

    self.authorBadge = Signal.merge(
      badge,
      badge.takeWhen(self.bindStylesProperty.signal)
    )
  }

  private var bindStylesProperty = MutableProperty(())
  public func bindStyles() {
    self.bindStylesProperty.value = ()
  }

  fileprivate let comment = MutableProperty<(Comment)?>(nil)
  public func configureWith(comment: Comment) {
    self.comment.value = comment
  }

  public let authorBadge: Signal<Comment.AuthorBadge, Never>
  public var authorImageURL: Signal<URL, Never>
  public let authorName: Signal<String, Never>
  public let body: Signal<String, Never>
  public let postTime: Signal<String, Never>

  public var inputs: RootCommentCellViewModelInputs { self }
  public var outputs: RootCommentCellViewModelOutputs { self }
}
