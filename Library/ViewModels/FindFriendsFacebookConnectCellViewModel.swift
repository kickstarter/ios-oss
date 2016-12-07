import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude
import FBSDKLoginKit

public protocol FindFriendsFacebookConnectCellViewModelInputs {
  /// Call when close button tapped to dismiss this view if used as a header
  func closeButtonTapped()

  /// Call to set where Friends View Controller was loaded from
  func configureWith(source source: FriendsSource)

  /// Call when Facebook Connect button is tapped
  func facebookConnectButtonTapped()

  /// Call when Facebook login completed with error
  func facebookLoginFail(error error: NSError?)

  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result result: FBSDKLoginManagerLoginResult)

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
  var postUserUpdatedNotification: Signal<NSNotification, NoError> { get }

  /// Emits when should error alert with AlertError
  var showErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits a User that can be used to replace the current user in the environment
  var updateUserInEnvironment: Signal<User, NoError> { get }
}

public protocol FindFriendsFacebookConnectCellViewModelType {
  var inputs: FindFriendsFacebookConnectCellViewModelInputs { get }
  var outputs: FindFriendsFacebookConnectCellViewModelOutputs { get }
}

public final class FindFriendsFacebookConnectCellViewModel: FindFriendsFacebookConnectCellViewModelType,
  FindFriendsFacebookConnectCellViewModelInputs, FindFriendsFacebookConnectCellViewModelOutputs {
  // swiftlint:disable function_body_length
  public init() {
    self.notifyDelegateToDismissHeader = self.closeButtonTappedProperty.signal

    let isLoading = MutableProperty(false)

    self.isLoading = isLoading.signal

    self.attemptFacebookLogin = self.facebookConnectButtonTappedProperty.signal

    let tokenString = self.facebookLoginSuccessProperty.signal.ignoreNil()
      .map { $0.token.tokenString ?? "" }

    let facebookConnect = tokenString
      .switchMap { token in
        AppEnvironment.current.apiService.facebookConnect(facebookAccessToken: token)
          .on(
            started: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
          })
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.updateUserInEnvironment = facebookConnect.values()

    self.postUserUpdatedNotification = self.userUpdatedProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.userUpdated, object: nil))

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

    let facebookLoginAttemptFailAlert = self.facebookLoginFailProperty.signal.ignoreNil()
      .map { AlertError.facebookLoginAttemptFail(error: $0) }

    self.showErrorAlert = Signal.merge([
      genericFacebookErrorAlert,
      facebookTokenFailAlert,
      facebookConnectAccountTakenAlert,
      facebookConnectEmailTakenAlert,
      facebookLoginAttemptFailAlert
    ])

    let source = configureWithProperty.signal

    self.hideCloseButton = source.map { $0 == FriendsSource.findFriends }

    source
      .takeWhen(self.showErrorAlert)
      .observeNext { AppEnvironment.current.koala.trackFacebookConnectError(source: $0) }

    source
      .takeWhen(self.facebookConnectButtonTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackFacebookConnect(source: $0) }

    source
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackCloseFacebookConnect(source: $0) }
  }
  // swiftlint:enable function_body_length

  public var inputs: FindFriendsFacebookConnectCellViewModelInputs { return self }
  public var outputs: FindFriendsFacebookConnectCellViewModelOutputs { return self }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    closeButtonTappedProperty.value = ()
  }

  private let configureWithProperty = MutableProperty<FriendsSource>(FriendsSource.findFriends)
  public func configureWith(source source: FriendsSource) {
    configureWithProperty.value = source
  }

  private let facebookConnectButtonTappedProperty = MutableProperty()
  public func facebookConnectButtonTapped() {
    facebookConnectButtonTappedProperty.value = ()
  }

  private let facebookLoginFailProperty = MutableProperty<NSError?>(nil)
  public func facebookLoginFail(error error: NSError?) {
    self.facebookLoginFailProperty.value = error
  }

  private let facebookLoginSuccessProperty = MutableProperty<FBSDKLoginManagerLoginResult?>(nil)
  public func facebookLoginSuccess(result result: FBSDKLoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }

  private let userUpdatedProperty = MutableProperty()
  public func userUpdated() {
    userUpdatedProperty.value = ()
  }

  public let attemptFacebookLogin: Signal<(), NoError>
  public let isLoading: Signal<Bool, NoError>
  public let notifyDelegateToDismissHeader: Signal<(), NoError>
  public let notifyDelegateUserFacebookConnected: Signal<(), NoError>
  public let postUserUpdatedNotification: Signal<NSNotification, NoError>
  public let updateUserInEnvironment: Signal<User, NoError>
  public let showErrorAlert: Signal<AlertError, NoError>
  public let hideCloseButton: Signal<Bool, NoError>
}
