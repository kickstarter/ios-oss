import KsApi
import Prelude
import ReactiveSwift

public struct CommentDialogData {
  public let project: Project
  public let update: Update?
  public let recipientName: String?
  public let context: KSRAnalytics.CommentDialogContext
}

public protocol CommentDialogViewModelInputs {
  /// Call when the view appears.
  func viewWillAppear()

  /// Call when the view disappears.
  func viewWillDisappear()

  /// Call with the project, update (optional), recipient name (optional) and context given to the view.
  func configureWith(
    project: Project,
    update: Update?,
    recipientName: String?,
    context: KSRAnalytics.CommentDialogContext
  )

  /// Call when the comment body text changes.
  func commentBodyChanged(_ text: String)

  /// Call when the post comment button is pressed.
  func postButtonPressed()

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()
}

public protocol CommentDialogViewModelOutputs {
  /// Emits a string that should be put into the body text view.
  var bodyTextViewText: Signal<String, Never> { get }

  /// Emits a boolean that determines if the post button is enabled.
  var postButtonEnabled: Signal<Bool, Never> { get }

  /// Emits a boolean that determines if the comment is currently posting.
  var loadingViewIsHidden: Signal<Bool, Never> { get }

  /// Emits the newly posted comment when the present of this dialog should be notified that posting
  /// was successful.
  var notifyPresenterCommentWasPostedSuccesfully: Signal<Comment, Never> { get }

  /// Emits when the dialog should notify its presenter that it wants to be dismissed.
  var notifyPresenterDialogWantsDismissal: Signal<(), Never> { get }

  /// Emits the string to be used as the subtitle of the comment dialog.
  var subtitle: Signal<String, Never> { get }

  /// Emits a boolean that determines if the keyboard should be shown or not.
  var showKeyboard: Signal<Bool, Never> { get }
}

public protocol CommentDialogViewModelErrors {
  /// Emits a string error description when there has been an error posting a comment.
  var presentError: Signal<String, Never> { get }
}

public protocol CommentDialogViewModelType {
  var inputs: CommentDialogViewModelInputs { get }
  var outputs: CommentDialogViewModelOutputs { get }
  var errors: CommentDialogViewModelErrors { get }
}

public final class CommentDialogViewModel: CommentDialogViewModelType,
  CommentDialogViewModelInputs,
  CommentDialogViewModelOutputs, CommentDialogViewModelErrors {
  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let viewWillDisappearProperty = MutableProperty(())
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  fileprivate let configurationDataProperty = MutableProperty<CommentDialogData?>(nil)
  public func configureWith(
    project: Project, update: Update?, recipientName: String?,
    context: KSRAnalytics.CommentDialogContext
  ) {
    self.configurationDataProperty.value = CommentDialogData(
      project: project, update: update,
      recipientName: recipientName, context: context
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
  public let notifyPresenterCommentWasPostedSuccesfully: Signal<Comment, Never>
  public let notifyPresenterDialogWantsDismissal: Signal<(), Never>
  public let subtitle: Signal<String, Never>
  public let showKeyboard: Signal<Bool, Never>

  public let presentError: Signal<String, Never>

  public var inputs: CommentDialogViewModelInputs { return self }
  public var outputs: CommentDialogViewModelOutputs { return self }
  public var errors: CommentDialogViewModelErrors { return self }

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

    let currentUser = self.viewWillAppearProperty.signal
      .map { _ in AppEnvironment.current.currentUser }

    // get an id needed to post a comment to either a project or a project update
    let commentableId = updateOrProject
      .flatMap { updateOrProject in
        updateOrProject.ifLeft { update in
          SignalProducer.init(value: encodeToBase64("FreeformPost-\(update.id)"))
        } ifRight: { project in
          SignalProducer.init(value: project.graphID)
        }
      }

    let commentPostedEvent = Signal.combineLatest(
      self.commentBodyProperty.signal,
      currentUser.signal.skipNil(),
      project.signal,
      commentableId.signal
    )
    .takeWhen(self.postButtonPressedProperty.signal)
    .switchMap { body, currentUser, project, commentableId in
      postComment(
        body,
        project: project,
        commentableId: commentableId,
        from: currentUser
      )
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
      .map { data in data.recipientName }
      .skipNil()
      .map { "@\($0): " }
  }
}

/**
 FIXME: Issues related to design that need to be discussed as a product change to the `ProjectActivitiesViewController` and removal of `CommentDialogViewController`.
 - Errors are not displayed to the user as the function uses optimistic posting and the `CommentDialogViewController` is dismissed before the error has a chance to be shown.
 - Replies are posted as comments on main thread with `@User` tagged.
 */

private func postComment(_ body: String,
                         project: Project,
                         commentableId: String,
                         from user: User)
  -> SignalProducer<Comment, ErrorEnvelope> {
  return CommentsViewModel.postCommentProducer(
    project: project,
    commentableId: commentableId,
    parentId: nil,
    user: user,
    body: body
  )
  .promoteError(ErrorEnvelope.self)
  .switchMap { (comment, _) -> SignalProducer<Comment, ErrorEnvelope> in
    guard comment.status == .failed else {
      return SignalProducer<Comment, ErrorEnvelope>(value: comment)
    }

    let failureEnvelope = ErrorEnvelope(
      errorMessages: [Strings.Something_went_wrong_please_try_again()],
      ksrCode: nil,
      httpCode: -1,
      exception: nil
    )

    return SignalProducer<Comment, ErrorEnvelope>(error: failureEnvelope)
  }
}
