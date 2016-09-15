import KsApi
import ReactiveCocoa
import Result
import Prelude

public protocol CommentsEmptyStateCellViewModelInputs {
  /// Call to configure with the project and update.
  func configureWith(project project: Project, update: Update?)

  /// Call when the leave a comment button is tapped.
  func leaveACommentTapped()

  /// Call when the login button is tapped.
  func loginTapped()
}

public protocol CommentsEmptyStateCellViewModelOutputs {
  /// Emits when we should go to the comment dialog screen.
  var goToCommentDialog: Signal<Void, NoError> { get }

  /// Emits when we should go to the login tout.
  var goToLoginTout: Signal<Void, NoError> { get }

  /// Emits a boolean to determine whether or not the Leave a comment button should be hidden.
  var leaveACommentButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean to determine whether or not the Login button should be hidden.
  var loginButtonHidden: Signal<Bool, NoError> { get }

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

    let backer = project
      .filter { $0.personalization.isBacking == true }

    let loggedOut = project
      .filter { $0.personalization.isBacking == nil }

    let nonBacker = project
      .filter { $0.personalization.isBacking == false }

    self.goToCommentDialog = self.leaveACommentTappedProperty.signal

    self.goToLoginTout = self.loginTappedProperty.signal

    self.leaveACommentButtonHidden = Signal.merge(
      backer.mapConst(false),
      loggedOut.mapConst(true),
      nonBacker.mapConst(true)
      )
      .skipRepeats()

    self.loginButtonHidden = Signal.merge(
      backer.mapConst(true),
      loggedOut.mapConst(false),
      nonBacker.mapConst(true)
      )
      .skipRepeats()

    let projectOrUpdateBackerSubtitle = self.projectAndUpdateProperty.signal.ignoreNil()
      .filter { $0.0.personalization.isBacking == true }
      .map {
        $0.1 == nil
          ? Strings.project_comments_empty_state_backer_message()
          : Strings.update_comments_empty_state_backer_message()
    }

    self.subtitleText = Signal.merge(
      projectOrUpdateBackerSubtitle,
      loggedOut.mapConst(Strings.project_comments_empty_state_logged_out_message_log_in()),
      nonBacker.mapConst(Strings.project_comments_empty_state_non_backer_message())
      )
      .skipRepeats()
  }

  private let leaveACommentTappedProperty = MutableProperty()
  public func leaveACommentTapped() {
    self.leaveACommentTappedProperty.value = ()
  }

  private let loginTappedProperty = MutableProperty()
  public func loginTapped() {
    self.loginTappedProperty.value = ()
  }

  private let projectAndUpdateProperty = MutableProperty<(Project, Update?)?>(nil)
  public func configureWith(project project: Project, update: Update?) {
    self.projectAndUpdateProperty.value = (project, update)
  }

  public let goToCommentDialog: Signal<Void, NoError>
  public let goToLoginTout: Signal<Void, NoError>
  public let leaveACommentButtonHidden: Signal<Bool, NoError>
  public let loginButtonHidden: Signal<Bool, NoError>
  public let subtitleText: Signal<String, NoError>

  public var inputs: CommentsEmptyStateCellViewModelInputs { return self }
  public var outputs: CommentsEmptyStateCellViewModelOutputs { return self }
}
