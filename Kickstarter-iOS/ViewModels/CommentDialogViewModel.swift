import ReactiveCocoa
import Models
import KsApi
import Result
import Library

internal protocol CommentDialogViewModelInputs {
  /// Call when the view appears.
  func viewWillAppear()

  /// Call with the project given to the view.
  func project(project: Project)

  /// Call when the comment body text changes.
  func commentBodyChanged(text: String)

  /// Call when the post comment button is pressed.
  func postButtonPressed()

  /// Call when the cancel button is pressed.
  func cancelButtonPressed()
}

internal protocol CommentDialogViewModelOutputs {
  /// Emits a boolean that determines if the post button is enabled.
  var postButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits when the dialog should communicate to its presenter that it wants to be dismissed.
  var notifyPresenterOfDismissal: Signal<(), NoError> { get }

  /// Emits a boolean that determines if the comment is currently posting.
  var commentIsPosting: Signal<Bool, NoError> { get }

  /// Emits when the comment has successfully posted.
  var commentPostedSuccessfully: Signal<(), NoError> { get }
}

internal protocol CommentDialogViewModelErrors {
  /// Emits a string error description when there has been an error posting a comment.
  var presentError: Signal<String, NoError> { get }
}

internal protocol CommentDialogViewModelType {
  var inputs: CommentDialogViewModelInputs { get }
  var outputs: CommentDialogViewModelOutputs { get }
  var errors: CommentDialogViewModelErrors { get }
}

internal final class CommentDialogViewModel: CommentDialogViewModelType, CommentDialogViewModelInputs,
CommentDialogViewModelOutputs, CommentDialogViewModelErrors {

  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  private let commentBodyProperty = MutableProperty("")
  internal func commentBodyChanged(text: String) {
    self.commentBodyProperty.value = text
  }

  private let postButtonPressedProperty = MutableProperty(())
  internal func postButtonPressed() {
    self.postButtonPressedProperty.value = ()
  }

  private let cancelButtonPressedProperty = MutableProperty(())
  internal func cancelButtonPressed() {
    self.cancelButtonPressedProperty.value = ()
  }

  internal let postButtonEnabled: Signal<Bool, NoError>
  internal let notifyPresenterOfDismissal: Signal<(), NoError>
  internal let commentIsPosting: Signal<Bool, NoError>
  internal let commentPostedSuccessfully: Signal<(), NoError>

  internal let presentError: Signal<String, NoError>

  internal var inputs: CommentDialogViewModelInputs { return self }
  internal var outputs: CommentDialogViewModelOutputs { return self }
  internal var errors: CommentDialogViewModelErrors { return self }

  internal init() {
    let isLoading = MutableProperty(false)

    let project = self.projectProperty.signal.ignoreNil()

    self.postButtonEnabled = Signal.merge([
      self.viewWillAppearProperty.signal.take(1).mapConst(false),
      self.commentBodyProperty.signal.map { !$0.isEmpty },
      isLoading.signal.map { !$0 }
      ])
      .skipRepeats()

    let commentPostedEvent = combineLatest(project, self.commentBodyProperty.signal)
      .takeWhen(self.postButtonPressedProperty.signal)
      .switchMap { project, body in
        AppEnvironment.current.apiService.postComment(body, toProject: project)
          .on(
            started: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
          })
          .materialize()
      }

    self.commentPostedSuccessfully = commentPostedEvent.values().ignoreValues()

    self.commentIsPosting = isLoading.signal

    self.notifyPresenterOfDismissal = Signal.merge([
      self.cancelButtonPressedProperty.signal,
      self.commentPostedSuccessfully
      ])

    self.presentError = commentPostedEvent.errors()
      .map { env in
        env.errorMessages.first ??
          localizedString(key: "comments.dialog.generic_error",
            defaultValue: "Sorry, your comment could not be posted.")
    }

    self.commentPostedSuccessfully
      .take(1)
      .observeNext { AppEnvironment.current.koala.trackProjectCommentCreate() }
  }
}
