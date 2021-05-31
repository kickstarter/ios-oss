import KsApi
import Prelude
import ReactiveSwift

public protocol CommentCellViewModelInputs {
  /// Call when bindStyles is called.
  func bindStyles()

  /// Call to configure with a Comment and Project
  func configureWith(comment: Comment, project: Project?)
}

public protocol CommentCellViewModelOutputs {
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

  /// Emits a Bool determining if the reply and flag buttons in the bottomColumnStackView are hidden.
  var replyButtonIsHidden: Signal<Bool, Never> { get }

  /// Emits whether or not the view replies stack view is hidden.
  var viewRepliesStackViewIsHidden: Signal<Bool, Never> { get }
}

public protocol CommentCellViewModelType {
  var inputs: CommentCellViewModelInputs { get }
  var outputs: CommentCellViewModelOutputs { get }
}

public final class CommentCellViewModel:
  CommentCellViewModelType, CommentCellViewModelInputs, CommentCellViewModelOutputs {
  public init() {
    let comment = self.commentAndProject.signal.skipNil()
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

    let badge = self.commentAndProject.signal
      .skipNil()
      .map { comment, _ in
        comment.author.id == AppEnvironment.current.currentUser?.id.description ? .you : comment.authorBadge
      }

    self.authorBadge = Signal.merge(
      badge,
      badge.takeWhen(self.bindStylesProperty.signal)
    )

    let isLoggedOut = self.commentAndProject.signal
      .ignoreValues()
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNil)

    let isNotABacker = self.commentAndProject.signal
      .skipNil()
      .map { _, project in project }
      .skipNil()
      .map(userIsBackingProject)
      .negate()

    self.replyButtonIsHidden = Signal.combineLatest(isLoggedOut, isNotABacker)
      .map { isLoggedOut, isNotABacker in isLoggedOut || isNotABacker }

    self.viewRepliesStackViewIsHidden = comment.map(\.replyCount)
      .map { $0 == 0 }
  }

  private var bindStylesProperty = MutableProperty(())
  public func bindStyles() {
    self.bindStylesProperty.value = ()
  }

  fileprivate let commentAndProject = MutableProperty<(Comment, Project?)?>(nil)
  public func configureWith(comment: Comment, project: Project?) {
    self.commentAndProject.value = (comment, project)
  }

  public let authorBadge: Signal<Comment.AuthorBadge, Never>
  public var authorImageURL: Signal<URL, Never>
  public let authorName: Signal<String, Never>
  public let body: Signal<String, Never>
  public let postTime: Signal<String, Never>
  public let replyButtonIsHidden: Signal<Bool, Never>
  public let viewRepliesStackViewIsHidden: Signal<Bool, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}
