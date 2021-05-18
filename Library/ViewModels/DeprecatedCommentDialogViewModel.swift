import KsApi
import Prelude
import ReactiveSwift

public struct DeprecatedCommentDialogData {
  public let project: Project
  public let update: Update?
  public let recipient: DeprecatedAuthor?
  public let context: KSRAnalytics.CommentDialogContext
}

public protocol DeprecatedCommentDialogViewModelInputs {
  /// Call when the view appears.
  func viewWillAppear()

  /// Call when the view disappears.
  func viewWillDisappear()

  /// Call with the project, update (optional), recipient (optional) and context given to the view.
  func configureWith(
    project: Project,
    update: Update?,
    recipient: DeprecatedAuthor?,
    context: KSRAnalytics.CommentDialogContext
  )

  /// Call when the comment body text changes.
  func commentBodyChanged(_ text: String)

  /// Call when the post comment button is pressed.
  func postButtonPressed()

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()
}

public protocol DeprecatedCommentDialogViewModelOutputs {
  /// Emits a string that should be put into the body text view.
  var bodyTextViewText: Signal<String, Never> { get }

  /// Emits a boolean that determines if the post button is enabled.
  var postButtonEnabled: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the comment is currently posting.
  var loadingViewIsHidden: Signal<Bool, Never> { get }

  /// Emits the newly posted comment when the present of this dialog should be notified that posting
  /// was successful.
  var notifyPresenterCommentWasPostedSuccesfully: Signal<DeprecatedComment, Never> { get }

  /// Emits when the dialog should notify its presenter that it wants to be dismissed.
  var notifyPresenterDialogWantsDismissal: Signal<(), Never> { get }

  /// Emits the string to be used as the subtitle of the comment dialog.
  var subtitle: Signal<String, Never> { get }

  /// Emits a boolean that determines if the keyboard should be shown or not.
  var showKeyboard: Signal<Bool, Never> { get }
}

public protocol DeprecatedCommentDialogViewModelErrors {
  /// Emits a string error description when there has been an error posting a comment.
  var presentError: Signal<String, Never> { get }
}

public protocol DeprecatedCommentDialogViewModelType {
  var inputs: DeprecatedCommentDialogViewModelInputs { get }
  var outputs: DeprecatedCommentDialogViewModelOutputs { get }
  var errors: DeprecatedCommentDialogViewModelErrors { get }
}

public final class DeprecatedCommentDialogViewModel: DeprecatedCommentDialogViewModelType,
  DeprecatedCommentDialogViewModelInputs,
  DeprecatedCommentDialogViewModelOutputs, DeprecatedCommentDialogViewModelErrors {
  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let viewWillDisappearProperty = MutableProperty(())
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  fileprivate let configurationDataProperty = MutableProperty<DeprecatedCommentDialogData?>(nil)
  public func configureWith(
    project: Project, update: Update?, recipient: DeprecatedAuthor?,
    context: KSRAnalytics.CommentDialogContext
  ) {
    self.configurationDataProperty.value = DeprecatedCommentDialogData(
      project: project, update: update,
      recipient: recipient, context: context
    )
  }

  fileprivate let commentBodyProperty = MutableProperty("")
  public func commentBodyChanged(_ text: String) {
    self.commentBodyProperty.value = text
  }

  fileprivate let postButtonPressedProperty = MutableProperty(())
  public func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }

  fileprivate let cancelButtonPressedProperty = MutableProperty(())
  public func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  public let bodyTextViewText: Signal<String, Never>
  public let postButtonEnabled: Signal<Bool, Never>
  public let loadingViewIsHidden: Signal<Bool, Never>
  public let notifyPresenterCommentWasPostedSuccesfully: Signal<DeprecatedComment, Never>
  public let notifyPresenterDialogWantsDismissal: Signal<(), Never>
  public let subtitle: Signal<String, Never>
  public let showKeyboard: Signal<Bool, Never>

  public let presentError: Signal<String, Never>

  public var inputs: DeprecatedCommentDialogViewModelInputs { return self }
  public var outputs: DeprecatedCommentDialogViewModelOutputs { return self }
  public var errors: DeprecatedCommentDialogViewModelErrors { return self }

  public init() {
    let isLoading = MutableProperty(false)

    let configurationData = self.configurationDataProperty.signal.skipNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    let project = configurationData
      .map { $0.project }

    let updateOrProject = configurationData
      .map { data in
        data.update.map(Either.left) ?? Either.right(data.project)
      }

    self.postButtonEnabled = Signal.merge([
      self.viewWillAppearProperty.signal.take(first: 1).mapConst(false),
      self.commentBodyProperty.signal.map { !$0.isEmpty },
      isLoading.signal.map(isFalse)
    ])
      .skipRepeats()

    let commentPostedEvent = Signal.combineLatest(self.commentBodyProperty.signal, updateOrProject)
      .takeWhen(self.postButtonPressedProperty.signal)
      .switchMap { body, updateOrProject in
        postComment(body, toUpdateOrComment: updateOrProject)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
            }
          )
          .materialize()
      }

    self.notifyPresenterCommentWasPostedSuccesfully = commentPostedEvent.values()

    self.loadingViewIsHidden = Signal.merge(
      self.viewWillAppearProperty.signal.mapConst(true),
      isLoading.signal.map(negate)
    )

    self.notifyPresenterDialogWantsDismissal = Signal.merge([
      self.cancelButtonPressedProperty.signal,
      self.notifyPresenterCommentWasPostedSuccesfully.ignoreValues()
    ])

    self.presentError = commentPostedEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.project_comments_error_posting()
      }

    self.subtitle = project
      .takeWhen(self.viewWillAppearProperty.signal)
      .map { $0.name }

    self.showKeyboard = Signal.merge(
      self.viewWillAppearProperty.signal.mapConst(true),
      self.viewWillDisappearProperty.signal.mapConst(false)
    )

    self.bodyTextViewText = configurationData
      .map { data in data.recipient?.name }
      .skipNil()
      .map { "@\($0): " }
  }
}

private func postComment(_ body: String, toUpdateOrComment updateOrComment: Either<Update, Project>)
  -> SignalProducer<DeprecatedComment, ErrorEnvelope> {
  switch updateOrComment {
  case let .left(update):
    return AppEnvironment.current.apiService.deprecatedPostComment(body, toUpdate: update)
  case let .right(project):
    return AppEnvironment.current.apiService.deprecatedPostComment(body, toProject: project)
  }
}
