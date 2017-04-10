import ReactiveSwift
import KsApi
import Result
import Prelude

public struct CommentDialogData {
  public let project: Project
  public let update: Update?
  public let recipient: User?
  public let context: Koala.CommentDialogContext
}

public protocol CommentDialogViewModelInputs {
  /// Call when the view appears.
  func viewWillAppear()

  /// Call when the view disappears.
  func viewWillDisappear()

  /// Call with the project, update (optional), recipient (optional) and context given to the view.
  func configureWith(project: Project,
                     update: Update?,
                     recipient: User?,
                     context: Koala.CommentDialogContext)

  /// Call when the comment body text changes.
  func commentBodyChanged(_ text: String)

  /// Call when the post comment button is pressed.
  func postButtonPressed()

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()
}

public protocol CommentDialogViewModelOutputs {
  /// Emits a string that should be put into the body text view.
  var bodyTextViewText: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the post button is enabled.
  var postButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the comment is currently posting.
  var loadingViewIsHidden: Signal<Bool, NoError> { get }

  /// Emits the newly posted comment when the present of this dialog should be notified that posting
  /// was successful.
  var notifyPresenterCommentWasPostedSuccesfully: Signal<Comment, NoError> { get }

  /// Emits when the dialog should notify its presenter that it wants to be dismissed.
  var notifyPresenterDialogWantsDismissal: Signal<(), NoError> { get }

  /// Emits the string to be used as the subtitle of the comment dialog.
  var subtitle: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the keyboard should be shown or not.
  var showKeyboard: Signal<Bool, NoError> { get }
}

public protocol CommentDialogViewModelErrors {
  /// Emits a string error description when there has been an error posting a comment.
  var presentError: Signal<String, NoError> { get }
}

public protocol CommentDialogViewModelType {
  var inputs: CommentDialogViewModelInputs { get }
  var outputs: CommentDialogViewModelOutputs { get }
  var errors: CommentDialogViewModelErrors { get }
}

public final class CommentDialogViewModel: CommentDialogViewModelType, CommentDialogViewModelInputs,
CommentDialogViewModelOutputs, CommentDialogViewModelErrors {

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let viewWillDisappearProperty = MutableProperty()
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  fileprivate let configurationDataProperty = MutableProperty<CommentDialogData?>(nil)
  public func configureWith(project: Project, update: Update?, recipient: User?,
                            context: Koala.CommentDialogContext) {

    self.configurationDataProperty.value = CommentDialogData(project: project, update: update,
                                                             recipient: recipient, context: context)
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

  public let bodyTextViewText: Signal<String, NoError>
  public let postButtonEnabled: Signal<Bool, NoError>
  public let loadingViewIsHidden: Signal<Bool, NoError>
  public let notifyPresenterCommentWasPostedSuccesfully: Signal<Comment, NoError>
  public let notifyPresenterDialogWantsDismissal: Signal<(), NoError>
  public let subtitle: Signal<String, NoError>
  public let showKeyboard: Signal<Bool, NoError>

  public let presentError: Signal<String, NoError>

  public var inputs: CommentDialogViewModelInputs { return self }
  public var outputs: CommentDialogViewModelOutputs { return self }
  public var errors: CommentDialogViewModelErrors { return self }

  // swiftlint:disable function_body_length
  public init() {
    let isLoading = MutableProperty(false)

    let configurationData = self.configurationDataProperty.signal.skipNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    let project = configurationData
      .map { $0.project }

    let updateOrProject = configurationData
      .map { data in
        return data.update.map(Either.left) ?? Either.right(data.project)
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
          })
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

    configurationData
      .takeWhen(self.viewWillAppearProperty.signal)
      .observeValues { data in
        AppEnvironment.current.koala.trackOpenedCommentEditor(
          project: data.project, update: data.update, context: data.context
        )
    }

    configurationData
      .takeWhen(self.cancelButtonPressedProperty.signal)
      .observeValues { data in
        AppEnvironment.current.koala.trackCanceledCommentEditor(
          project: data.project, update: data.update, context: data.context
        )
    }

    configurationData
      .takePairWhen(self.notifyPresenterCommentWasPostedSuccesfully)
      .observeValues { data, comment in
        if let update = data.update {
          AppEnvironment.current.koala.trackCommentCreate(
            comment: comment, update: update, project: data.project
          )
        } else {
          AppEnvironment.current.koala.trackCommentCreate(comment: comment, project: data.project)
        }
        AppEnvironment.current.koala.trackPostedComment(
          project: data.project, update: data.update, context: data.context
        )
    }
  }
  // swiftlint:enable function_body_length
}

private func postComment(_ body: String, toUpdateOrComment updateOrComment: Either<Update, Project>)
  -> SignalProducer<Comment, ErrorEnvelope> {

    switch updateOrComment {
    case let .left(update):
      return AppEnvironment.current.apiService.postComment(body, toUpdate: update)
    case let .right(project):
      return AppEnvironment.current.apiService.postComment(body, toProject: project)
    }
}
