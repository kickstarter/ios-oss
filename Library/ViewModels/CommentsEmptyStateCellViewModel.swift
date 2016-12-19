import KsApi
import ReactiveSwift
import Result
import Prelude

public protocol CommentsEmptyStateCellViewModelInputs {
  /// Call when back this project button is tapped.
  func backProjectTapped()

  /// Call to configure with the project and update.
  func configureWith(project: Project, update: Update?)

  /// Call when the leave a comment button is tapped.
  func leaveACommentTapped()

  /// Call when the login button is tapped.
  func loginTapped()
}

public protocol CommentsEmptyStateCellViewModelOutputs {
  /// Emits a boolean to determine whether or not backProjectButton is hidden.
  var backProjectButtonHidden: Signal<Bool, NoError> { get }

  /// Emits when to navigate back to the project.
  var goBackToProject: Signal<(), NoError> { get }

  /// Emits when we should go to the comment dialog screen.
  var goToCommentDialog: Signal<Void, NoError> { get }

  /// Emits when we should go to the login tout.
  var goToLoginTout: Signal<Void, NoError> { get }

  /// Emits a boolean to determine whether or not the Leave a comment button should be hidden.
  var leaveACommentButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean to determine whether or not the Login button should be hidden.
  var loginButtonHidden: Signal<Bool, NoError> { get }

  /// Emits whether subtitle label is hidden.
  var subtitleIsHidden: Signal<Bool, NoError> { get }

  /// Emits the subtitle label text.
  var subtitleText: Signal<String, NoError> { get }
}

public protocol CommentsEmptyStateCellViewModelType {
  var inputs: CommentsEmptyStateCellViewModelInputs { get }
  var outputs: CommentsEmptyStateCellViewModelOutputs { get }
}

public final class CommentsEmptyStateCellViewModel: CommentsEmptyStateCellViewModelType,
CommentsEmptyStateCellViewModelInputs, CommentsEmptyStateCellViewModelOutputs {

  public init() {
    let project = self.projectAndUpdateProperty.signal.ignoreNil().map(first)

    let projectData = project.map {
      ProjectEmptyCommentsData(
        isCreator: AppEnvironment.current.currentUser == $0.creator,
        isBacker: $0.personalization.isBacking == true,
        isLoggedIn: AppEnvironment.current.currentUser != nil
      )
    }

    self.backProjectButtonHidden = projectData.map { (!$0.isLoggedIn || $0.isCreator) ? true : $0.isBacker }

    self.leaveACommentButtonHidden = projectData.map { !$0.isLoggedIn ? true : !$0.isBacker }

    self.loginButtonHidden = projectData.map { $0.isLoggedIn }

    self.subtitleIsHidden = projectData.map { $0.isBacker || $0.isCreator }

    self.subtitleText = projectData
      .filter { !$0.isBacker && !$0.isCreator }
      .map { $0.isLoggedIn
        ? Strings.Become_a_backer_to_leave_a_comment()
        : Strings.Log_in_to_leave_a_comment()
    }

    self.goToCommentDialog = self.leaveACommentTappedProperty.signal

    self.goToLoginTout = self.loginTappedProperty.signal

    self.goBackToProject = self.backProjectTappedProperty.signal
  }

  fileprivate let backProjectTappedProperty = MutableProperty()
  public func backProjectTapped() {
    self.backProjectTappedProperty.value = ()
  }

  fileprivate let leaveACommentTappedProperty = MutableProperty()
  public func leaveACommentTapped() {
    self.leaveACommentTappedProperty.value = ()
  }

  fileprivate let loginTappedProperty = MutableProperty()
  public func loginTapped() {
    self.loginTappedProperty.value = ()
  }

  fileprivate let projectAndUpdateProperty = MutableProperty<(Project, Update?)?>(nil)
  public func configureWith(project: Project, update: Update?) {
    self.projectAndUpdateProperty.value = (project, update)
  }

  public let backProjectButtonHidden: Signal<Bool, NoError>
  public let goBackToProject: Signal<(), NoError>
  public let goToCommentDialog: Signal<Void, NoError>
  public let goToLoginTout: Signal<Void, NoError>
  public let leaveACommentButtonHidden: Signal<Bool, NoError>
  public let loginButtonHidden: Signal<Bool, NoError>
  public let subtitleIsHidden: Signal<Bool, NoError>
  public let subtitleText: Signal<String, NoError>

  public var inputs: CommentsEmptyStateCellViewModelInputs { return self }
  public var outputs: CommentsEmptyStateCellViewModelOutputs { return self }
}

private struct ProjectEmptyCommentsData {
  fileprivate let isCreator: Bool
  fileprivate let isBacker: Bool
  fileprivate let isLoggedIn: Bool
}
