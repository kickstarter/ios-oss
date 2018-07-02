import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude
import FBSDKLoginKit

public protocol FindFriendsFacebookConnectCellViewModelInputs {
  /// Call when close button tapped to dismiss this view if used as a header
  func closeButtonTapped()

  /// Call to set where Friends View Controller was loaded from
  func configureWith(value: FacebookConnectCellValue)

  /// Call when Facebook Connect button is tapped
  func facebookConnectButtonTapped()

  /// Call when Facebook login completed with error
  func facebookLoginFail(error: Error?)

  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result: FBSDKLoginManagerLoginResult)

  /// Call when the current user has been updated in the environment
  func userUpdated()
}

public protocol FindFriendsFacebookConnectCellViewModelOutputs {
  /// Emits when Facebook login should start
  var attemptFacebookLogin: Signal<(), NoError> { get }

  /// Emits whether close button should hide
  var hideCloseButton: Signal<Bool, NoError> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits when should notify delegate to dismiss this view if used as a header
  var notifyDelegateToDismissHeader: Signal<(), NoError> { get }

  /// Emits when should notify delegate that user successfully connected to Facebook
  var notifyDelegateUserFacebookConnected: Signal<(), NoError> { get }

  /// Emits when a user updated notification should be posted
  var postUserUpdatedNotification: Signal<Notification, NoError> { get }

  /// Emits when should error alert with AlertError
  var showErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits a User that can be used to replace the current user in the environment
  var updateUserInEnvironment: Signal<User, NoError> { get }

  /// Emits the cell's title
  var facebookConnectCellTitle: Signal<String, NoError> { get }

  /// Emits the cell's description
  var facebookConnectCellSubtitle: Signal<String, NoError> { get }

  /// Emits the button's title
  var facebookConnectButtonTitle: Signal<String, NoError> { get }
}

public protocol FindFriendsFacebookConnectCellViewModelType {
  var inputs: FindFriendsFacebookConnectCellViewModelInputs { get }
  var outputs: FindFriendsFacebookConnectCellViewModelOutputs { get }
}

public final class FindFriendsFacebookConnectCellViewModel: FindFriendsFacebookConnectCellViewModelType,
  FindFriendsFacebookConnectCellViewModelInputs, FindFriendsFacebookConnectCellViewModelOutputs {
    public init() {
    self.notifyDelegateToDismissHeader = self.closeButtonTappedProperty.signal

    let isLoading: MutableProperty<Bool> = MutableProperty(false)

    self.isLoading = isLoading.signal

    self.attemptFacebookLogin = self.facebookConnectButtonTappedProperty.signal

    let tokenString: Signal<String, NoError> = self.facebookLoginSuccessProperty.signal.skipNil()
      .map { $0.token.tokenString ?? "" }

    let facebookConnect = tokenString
      .switchMap { token in
        AppEnvironment.current.apiService.facebookConnect(facebookAccessToken: token)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
          })
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.updateUserInEnvironment = facebookConnect.values()

    self.postUserUpdatedNotification = self.userUpdatedProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated))

    self.notifyDelegateUserFacebookConnected = self.userUpdatedProperty.signal

    let genericFacebookErrorAlert = facebookConnect.errors()
      .filter { env in
          env.ksrCode != .FacebookInvalidAccessToken &&
          env.ksrCode != .FacebookConnectAccountTaken &&
          env.ksrCode != .FacebookConnectEmailTaken
      }
      .map { AlertError.genericFacebookError(envelope: $0) }

    let facebookTokenFailAlert = facebookConnect.errors()
      .filter { $0.ksrCode == .FacebookInvalidAccessToken }
      .ignoreValues()
      .mapConst(AlertError.facebookTokenFail)

    let facebookConnectAccountTakenAlert = facebookConnect.errors()
      .filter { $0.ksrCode == .FacebookConnectAccountTaken }
      .map { AlertError.facebookConnectAccountTaken(envelope: $0) }

    let facebookConnectEmailTakenAlert = facebookConnect.errors()
      .filter { $0.ksrCode == .FacebookConnectEmailTaken }
      .map { AlertError.facebookConnectEmailTaken(envelope: $0) }

    let facebookLoginAttemptFailAlert = self.facebookLoginFailProperty.signal
      .map { $0 as NSError? }
      .skipNil()
      .map(AlertError.facebookLoginAttemptFail)

    self.showErrorAlert = Signal.merge([
      genericFacebookErrorAlert,
      facebookTokenFailAlert,
      facebookConnectAccountTakenAlert,
      facebookConnectEmailTakenAlert,
      facebookLoginAttemptFailAlert
    ])

    let source = configureWithProperty.signal.skipNil().map { $0.source }
    let cellType = configureWithProperty.signal.skipNil().map { $0.connectionType }

    self.hideCloseButton = source.map { $0 == FriendsSource.findFriends }

      self.facebookConnectCellTitle = cellType.signal.map { FindFriendsFacebookConnectCellViewModel.titleText(for: $0) }
      self.facebookConnectCellSubtitle = cellType.signal.map { FindFriendsFacebookConnectCellViewModel.subtitleText(for: $0) }
      self.facebookConnectButtonTitle = cellType.signal.map { FindFriendsFacebookConnectCellViewModel.buttonText(for: $0) }

    source
      .takeWhen(self.showErrorAlert)
      .observeValues { AppEnvironment.current.koala.trackFacebookConnectError(source: $0) }

    source
      .takeWhen(self.facebookConnectButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackFacebookConnect(source: $0) }

    source
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackCloseFacebookConnect(source: $0) }
  }

  public var inputs: FindFriendsFacebookConnectCellViewModelInputs { return self }
  public var outputs: FindFriendsFacebookConnectCellViewModelOutputs { return self }

  fileprivate let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    closeButtonTappedProperty.value = ()
  }

  fileprivate let configureWithProperty = MutableProperty<FacebookConnectCellValue?>(nil)
  public func configureWith(value: FacebookConnectCellValue) {
    configureWithProperty.value = value
  }

  fileprivate let facebookConnectButtonTappedProperty = MutableProperty(())
  public func facebookConnectButtonTapped() {
    facebookConnectButtonTappedProperty.value = ()
  }

  fileprivate let facebookLoginFailProperty = MutableProperty<Error?>(nil)
  public func facebookLoginFail(error: Error?) {
    self.facebookLoginFailProperty.value = error
  }

  fileprivate let facebookLoginSuccessProperty = MutableProperty<FBSDKLoginManagerLoginResult?>(nil)
  public func facebookLoginSuccess(result: FBSDKLoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }

  fileprivate let userUpdatedProperty = MutableProperty(())
  public func userUpdated() {
    userUpdatedProperty.value = ()
  }

  public let attemptFacebookLogin: Signal<(), NoError>
  public let isLoading: Signal<Bool, NoError>
  public let notifyDelegateToDismissHeader: Signal<(), NoError>
  public let notifyDelegateUserFacebookConnected: Signal<(), NoError>
  public let postUserUpdatedNotification: Signal<Notification, NoError>
  public let updateUserInEnvironment: Signal<User, NoError>
  public let showErrorAlert: Signal<AlertError, NoError>
  public let hideCloseButton: Signal<Bool, NoError>
  public let facebookConnectCellTitle: Signal<String, NoError>
  public let facebookConnectCellSubtitle: Signal<String, NoError>
  public let facebookConnectButtonTitle: Signal<String, NoError>
}

extension FindFriendsFacebookConnectCellViewModel {
  fileprivate static func titleText(for connectionType: FacebookConnectionType) -> String {
    switch connectionType {
    case .connect:
      return Strings.Discover_more_projects()
    case .reconnect:
      return Strings.Facebook_reconnect()
    }
  }

  fileprivate static func subtitleText(for connectionType: FacebookConnectionType) -> String {
    switch connectionType {
    case .connect:
      return Strings.Connect_with_Facebook_to_follow_friends_and_get_notified()
    case .reconnect:
      return Strings.Facebook_reconnect_description()
    }
  }

  fileprivate static func buttonText(for connectionType: FacebookConnectionType) -> String {
    switch connectionType {
    case .connect:
      return Strings.general_social_buttons_connect_with_facebook()
    case .reconnect:
      return "Continue"
    }
  }
}
