import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol CommentCellViewModelInputs {
  /// Call when bindStyles is called.
  func bindStyles()

  /// Call to configure with a Comment and Project
  func configureWith(comment: Comment, project: Project?)

  /// Call when the textView delegate method for shouldInteractWith url is called
  func linkTapped(url: URL)

  /// Call when the reply button is tapped
  func replyButtonTapped()

  /// Call when the view replies button is tapped
  func viewRepliesButtonTapped()
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

  /// Emits a Bool determining if the bottomRowStackView is hidden.
  var bottomRowStackViewIsHidden: Signal<Bool, Never> { get }

  /// Emits the current status of a comment
  var commentStatus: Signal<Comment.Status, Never> { get }

  /// Emits a Bool determining if the flag button in the bottomRowStackView is hidden.
  var flagButtonIsHidden: Signal<Bool, Never> { get }

  /// Emits an URL for the CommentRemovedCellDelegate to use as an argument.
  var notifyDelegateLinkTappedWithURL: Signal<URL, Never> { get }

  /// Emits text relative time the comment was posted.
  var postTime: Signal<String, Never> { get }

  /// Emits a  Bool determining if the posted button is hidden
  var postedButtonIsHidden: Signal<Bool, Never> { get }

  /// Emits a Bool determining if the reply button in the bottomRowStackView are hidden.
  var replyButtonIsHidden: Signal<Bool, Never> { get }

  /// Emits a `Comment` for the cell that reply button is clicked for.
  var replyCommentTapped: Signal<Comment, Never> { get }

  /// Emits whether the content of the cell should be indented.
  var shouldIndentContent: Signal<Bool, Never> { get }

  /// Emits a `Comment` for the cell that view replies button is clicked for.
  var viewCommentReplies: Signal<Comment, Never> { get }

  /// Emits whether or not the view replies stack view is hidden.
  var viewRepliesViewHidden: Signal<Bool, Never> { get }
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

    let status = comment.map(\.status)

    self.commentStatus = Signal.merge(
      status,
      status.takeWhen(self.bindStylesProperty.signal)
    )

    self.postTime = comment.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .medium, timeStyle: .short)
    }

    self.postedButtonIsHidden = self.commentStatus.map { $0 != .retrySuccess }

    let badge = self.commentAndProject.signal
      .skipNil()
      .map { comment, _ in
        comment.author.id == AppEnvironment.current.currentUser?.id.description ? .you : comment.authorBadge
      }

    self.authorBadge = Signal.merge(
      badge,
      badge.takeWhen(self.bindStylesProperty.signal)
    )

    self.flagButtonIsHidden = self.commentAndProject.signal
      .ignoreValues()
      .map(featureCommentFlaggingIsEnabled)
      .map(isFalse)

    let isLoggedOut = self.commentAndProject.signal
      .ignoreValues()
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNil)

    let isNotABackerCreatorOrCollaborator = self.commentAndProject.signal
      .skipNil()
      .map { _, project in project }
      .skipNil()
      .map(userIsBackingCreatorOrCollaborator)
      .negate()

    let isReply = comment.map { $0.isReply }

    // If the user is either logged out, not backing or the flag is disabled, hide replyButton.
    self.replyButtonIsHidden = Signal.combineLatest(isLoggedOut, isNotABackerCreatorOrCollaborator)
      .map(replyButtonHidden)

    // If both the replyButton and flagButton should be hidden, the entire stackview will be hidden too.
    self.bottomRowStackViewIsHidden = Signal.combineLatest(
      self.flagButtonIsHidden.signal,
      self.replyButtonIsHidden.signal,
      isReply
    ).map { flagButtonIsHidden, replyButtonIsHidden, isReply in
      (flagButtonIsHidden && replyButtonIsHidden) || isReply
    }

    self.notifyDelegateLinkTappedWithURL = self.linkTappedProperty.signal.skipNil()

    // If there are no replies or if the feature flag returns false, hide the stack view.
    self.viewRepliesViewHidden = comment.map(\.replyCount)
      .map(viewRepliesStackViewHidden)

    self.replyCommentTapped = comment.takeWhen(self.replyButtonTappedProperty.signal)
    self.viewCommentReplies = comment.takeWhen(self.viewRepliesButtonTappedProperty.signal)

    self.shouldIndentContent = isReply
      .takeWhen(self.bindStylesProperty.signal)
  }

  private var bindStylesProperty = MutableProperty(())
  public func bindStyles() {
    self.bindStylesProperty.value = ()
  }

  fileprivate let commentAndProject = MutableProperty<(Comment, Project?)?>(nil)
  public func configureWith(comment: Comment, project: Project?) {
    self.commentAndProject.value = (comment, project)
  }

  fileprivate let linkTappedProperty = MutableProperty<URL?>(nil)
  public func linkTapped(url: URL) {
    self.linkTappedProperty.value = url
  }

  private var replyButtonTappedProperty = MutableProperty(())
  public func replyButtonTapped() {
    self.replyButtonTappedProperty.value = ()
  }

  fileprivate let viewRepliesButtonTappedProperty = MutableProperty(())
  public func viewRepliesButtonTapped() {
    self.viewRepliesButtonTappedProperty.value = ()
  }

  public let authorBadge: Signal<Comment.AuthorBadge, Never>
  public var authorImageURL: Signal<URL, Never>
  public let authorName: Signal<String, Never>
  public let body: Signal<String, Never>
  public let bottomRowStackViewIsHidden: Signal<Bool, Never>
  public let commentStatus: Signal<Comment.Status, Never>
  public let flagButtonIsHidden: Signal<Bool, Never>
  public let notifyDelegateLinkTappedWithURL: Signal<URL, Never>
  public let postTime: Signal<String, Never>
  public let postedButtonIsHidden: Signal<Bool, Never>
  public let replyButtonIsHidden: Signal<Bool, Never>
  public let replyCommentTapped: Signal<Comment, Never>
  public let shouldIndentContent: Signal<Bool, Never>
  public let viewCommentReplies: Signal<Comment, Never>
  public let viewRepliesViewHidden: Signal<Bool, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}

private func userIsBackingCreatorOrCollaborator(_ project: Project) -> Bool {
  return (project.personalization.backing != nil || project.personalization.isBacking == .some(true)) ||
    !project.memberData.permissions.isEmpty
}

private func replyButtonHidden(isLoggedOut: Bool, isNotABackerCreatorOrCollaborator: Bool) -> Bool {
  return isLoggedOut || isNotABackerCreatorOrCollaborator
}

private func viewRepliesStackViewHidden(_ replyCount: Int) -> Bool {
  return replyCount == 0
}
