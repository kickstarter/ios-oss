import Library
import ReactiveCocoa
import Result
import Models
import KsApi

internal protocol CommentsViewModelInputs {
  /// Call when the view appears.
  func viewWillAppear()

  /// Call with the project given to the view.
  func project(project: Project)

  /// Call when the comment button is pressed.
  func commentButtonPressed()

  /// Call when the 'back this project' button is pressed in the non-backer empty state.
  func backProjectButtonPressed()

  /// Call when the comment dialog has posted a comment.
  func commentPosted()

  /// Call when the cancel button is pressed in the comment dialog.
  func cancelCommentButtonPressed()
}

internal protocol CommentsViewModelOutputs {
  /// Emits a list of comments that should be displayed.
  var comments: Signal<[Comment], NoError> { get }

  /// Emits a boolean that determines if the comment button is visible.
  var commentButtonVisible: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the logged-out empty state is visible.
  var loggedOutEmptyStateVisible: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the logged-in, non-backer empty state is visible.
  var nonBackerEmptyStateVisible: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the logged-in, backer empty state is visible.
  var backerEmptyStateVisible: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the posting dialog should be presented or dismissed.
  var postCommentDialogPresented: Signal<Bool, NoError> { get }
}

internal protocol CommentsViewModelType {
  var inputs: CommentsViewModelInputs { get }
  var outputs: CommentsViewModelOutputs { get }
}

internal final class CommentsViewModel: CommentsViewModelType, CommentsViewModelInputs,
CommentsViewModelOutputs {

  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  private let commentButtonPressedProperty = MutableProperty(())
  internal func commentButtonPressed() {
    self.commentButtonPressedProperty.value = ()
  }

  private let backProjectButtonPressedProperty = MutableProperty(())
  internal func backProjectButtonPressed() {
    self.backProjectButtonPressedProperty.value = ()
  }

  private let commentPostedProperty = MutableProperty(())
  func commentPosted() {
    self.commentPostedProperty.value = ()
  }

  private let cancelCommentButtonPressedProperty = MutableProperty(())
  func cancelCommentButtonPressed() {
    self.cancelCommentButtonPressedProperty.value = ()
  }

  internal let comments: Signal<[Comment], NoError>
  internal let commentButtonVisible: Signal<Bool, NoError>
  internal let loggedOutEmptyStateVisible: Signal<Bool, NoError>
  internal let nonBackerEmptyStateVisible: Signal<Bool, NoError>
  internal let backerEmptyStateVisible: Signal<Bool, NoError>
  internal let postCommentDialogPresented: Signal<Bool, NoError>

  internal var inputs: CommentsViewModelInputs { return self }
  internal var outputs: CommentsViewModelOutputs { return self }

  internal init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.comments = Signal.merge([
        project.take(1),
        project.takeWhen(self.commentPostedProperty.signal)
      ])
      .flatMap {
        AppEnvironment.current.apiService.fetchComments(project: $0)
          .map { env in env.comments }
          .demoteErrors()
    }

    self.loggedOutEmptyStateVisible = combineLatest(project, self.comments)
      .map { project, comments in
        project.isBacking == nil && comments.count == 0
      }
      .skipWhile { visible in !visible }
      .skipRepeats()

    self.nonBackerEmptyStateVisible = combineLatest(project, self.comments)
      .map { project, comments in
        project.isBacking == false && comments.count == 0
      }
      .skipWhile { visible in !visible }
      .skipRepeats()

    self.backerEmptyStateVisible = combineLatest(project, self.comments)
      .map { project, comments in
        project.isBacking == true && comments.count == 0
      }
      .skipWhile { visible in !visible }
      .skipRepeats()

    self.commentButtonVisible = project.map { $0.isBacking == true }.skipRepeats()

    self.postCommentDialogPresented = Signal.merge([
      self.commentButtonPressedProperty.signal.mapConst(true),
      self.commentPostedProperty.signal.mapConst(false),
      self.cancelCommentButtonPressedProperty.signal.mapConst(false)
      ])
      .skipRepeats()

    self.viewWillAppearProperty.signal.take(1)
      .observeNext { _ in AppEnvironment.current.koala.trackProjectCommentsView() }
  }
}
