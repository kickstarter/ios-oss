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
  func configureWith(source: FriendsSource)

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

    let source = configureWithProperty.signal.skipNil().map { $0 }
    let connectionType = configureWithProperty.signal.skipNil().map { _ in
      FindFriendsFacebookConnectCellViewModel.connectionType(user: AppEnvironment.current.currentUser)
    }

    self.hideCloseButton = source.map { $0 == FriendsSource.findFriends }

    self.facebookConnectCellTitle = connectionType.signal
      .skipNil()
      .map { $0.titleText }
    self.facebookConnectCellSubtitle = connectionType.signal
      .skipNil()
      .map { $0.subtitleText }
    self.facebookConnectButtonTitle = connectionType.signal
      .skipNil()
      .map { $0.buttonText }

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

  fileprivate let configureWithProperty = MutableProperty<FriendsSource?>(nil)
  public func configureWith(source: FriendsSource) {
    configureWithProperty.value = source
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
  public let facebookConnectButtonTitle: Signal<String, NoError>
  public let facebookConnectCellTitle: Signal<String, NoError>
  public let facebookConnectCellSubtitle: Signal<String, NoError>
  public let hideCloseButton: Signal<Bool, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let notifyDelegateToDismissHeader: Signal<(), NoError>
  public let notifyDelegateUserFacebookConnected: Signal<(), NoError>
  public let postUserUpdatedNotification: Signal<Notification, NoError>
  public let updateUserInEnvironment: Signal<User, NoError>
  public let showErrorAlert: Signal<AlertError, NoError>
}

extension FindFriendsFacebookConnectCellViewModel {
  public static func showFacebookConnectionSection(for user: User?) -> Bool {
    guard let isFacebookConnected = user?.facebookConnected else {
      return true
    }

    let needsFreshFacebookToken = user?.needsFreshFacebookToken ?? false

    // Show section in "reconnect" state if facebook connected but requiring a new token
    return !isFacebookConnected || (isFacebookConnected
      && needsFreshFacebookToken)
  }

  private static func connectionType(user: User?) -> FacebookConnectionType? {
    guard let isFacebookConnected = user?.facebookConnected else {
      return .connect
    }

    let needsRefresh = user?.needsFreshFacebookToken ?? false

    if isFacebookConnected && needsRefresh {
      return .reconnect
    }

    return .connect
  }
}
