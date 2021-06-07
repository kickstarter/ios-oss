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

  /// Emits a Bool determining if the bottomRowStackView is hidden.
  var bottomRowStackViewIsHidden: Signal<Bool, Never> { get }

  /// Emits a Bool determining if the flag button in the bottomRowStackView is hidden.
  var flagButtonIsHidden: Signal<Bool, Never> { get }

  /// Emits text  relative time the comment was posted.
  var postTime: Signal<String, Never> { get }

  /// Emits a Bool determining if the reply button in the bottomRowStackView are hidden.
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

    self.flagButtonIsHidden = self.commentAndProject.signal
      .map { _ in
        guard let isFeatureEnabled = AppEnvironment.current.optimizelyClient?
          .isFeatureEnabled(featureKey: OptimizelyFeature.Key.commentFlaggingEnabled.rawValue)
        else { return true }

        // If the feature is enabled, the flag button should be visible.
        return !isFeatureEnabled
      }

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

    // If the user is either logged out, not backing or the flag is disabled, hide replyButton.
    self.replyButtonIsHidden = Signal.combineLatest(isLoggedOut, isNotABacker)
      .map(replyButtonHidden)

    // If both the replyButton and flagButton should be hidden, the entire stackview will be hidden too.
    self.bottomRowStackViewIsHidden = Signal.combineLatest(
      self.flagButtonIsHidden.signal,
      self.replyButtonIsHidden.signal
    ).map { flagButtonIsHidden, replyButtonIsHidden in
      flagButtonIsHidden && replyButtonIsHidden
    }

    // If there are no replies or if the feature flag returns false, hide the stack view.
    self.viewRepliesStackViewIsHidden = comment.map(\.replyCount)
      .map(viewRepliesStackViewHidden)
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
  public let bottomRowStackViewIsHidden: Signal<Bool, Never>
  public let flagButtonIsHidden: Signal<Bool, Never>
  public let postTime: Signal<String, Never>
  public let replyButtonIsHidden: Signal<Bool, Never>
  public let viewRepliesStackViewIsHidden: Signal<Bool, Never>

  public var inputs: CommentCellViewModelInputs { self }
  public var outputs: CommentCellViewModelOutputs { self }
}

private func commentThreadingRepliesEnabled() -> Bool {
  return AppEnvironment.current.optimizelyClient?
    .isFeatureEnabled(featureKey: OptimizelyFeature.Key.commentThreadingRepliesEnabled.rawValue) ?? false
}

private func replyButtonHidden(isLoggedOut: Bool, isNotABacker: Bool) -> Bool {
  guard commentThreadingRepliesEnabled() else { return true }
  return isLoggedOut || isNotABacker
}

private func viewRepliesStackViewHidden(_ replyCount: Int) -> Bool {
  guard commentThreadingRepliesEnabled() else { return true }
  return replyCount == 0
}
