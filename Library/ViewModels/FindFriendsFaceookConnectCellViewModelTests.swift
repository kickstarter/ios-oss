@testable import FBSDKLoginKit
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit.UIActivity
import XCTest

final class FindFriendsFacebookConnectCellViewModelTests: TestCase {
  let vm: FindFriendsFacebookConnectCellViewModelType = FindFriendsFacebookConnectCellViewModel()

  let attemptFacebookLogin = TestObserver<(), Never>()
  let hideCloseButton = TestObserver<Bool, Never>()
  let isLoading = TestObserver<Bool, Never>()
  let notifyPresenterToDismissHeader = TestObserver<(), Never>()
  let notifyPresenterUserFacebookConnected = TestObserver<(), Never>()
  let postUserUpdatedNotification = TestObserver<Notification.Name, Never>()
  let updateUserInEnvironment = TestObserver<User, Never>()
  let showErrorAlert = TestObserver<AlertError, Never>()
  let subtitle = TestObserver<String, Never>()
  let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.attemptFacebookLogin.observe(self.attemptFacebookLogin.observer)
    self.vm.outputs.facebookConnectCellTitle.observe(self.title.observer)
    self.vm.outputs.facebookConnectCellSubtitle.observe(self.subtitle.observer)
    self.vm.outputs.hideCloseButton.observe(self.hideCloseButton.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.notifyDelegateToDismissHeader.observe(self.notifyPresenterToDismissHeader.observer)
    self.vm.outputs.notifyDelegateUserFacebookConnected
      .observe(self.notifyPresenterUserFacebookConnected.observer)
    self.vm.outputs.postUserUpdatedNotification.map { $0.name }
      .observe(self.postUserUpdatedNotification.observer)
    self.vm.outputs.updateUserInEnvironment.observe(self.updateUserInEnvironment.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
  }

  func testHideCloseButton() {
    self.vm.inputs.configureWith(source: .findFriends)

    self.hideCloseButton.assertValue(true)
  }

  func testShowCloseButton() {
    self.vm.inputs.configureWith(source: .activity)

    self.hideCloseButton.assertValue(false)
  }

  func testDismissal() {
    self.vm.inputs.configureWith(source: .activity)

    self.notifyPresenterToDismissHeader.assertValueCount(0)

    self.vm.inputs.closeButtonTapped()

    self.notifyPresenterToDismissHeader.assertValueCount(1)

    XCTAssertEqual(["Close Facebook Connect"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })
  }

  func testLabels_NonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: .activity)

      title.assertValue(Strings.Discover_more_projects())
      subtitle.assertValue(Strings.Connect_with_Facebook_to_follow_friends_and_get_notified())
    }
  }

  func testLabels_needsReconnect() {
    withEnvironment(
      currentUser: User.template
        |> \.facebookConnected .~ true
        |> \.needsFreshFacebookToken .~ true
    ) {
      vm.inputs.configureWith(source: .activity)

      title.assertValue(Strings.Facebook_reconnect())
      subtitle.assertValue(Strings.Facebook_reconnect_description())
    }
  }

  func testFacebookConnectFlow_Success() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: .activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook Login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook Connect emitted")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      vm.inputs.facebookLoginSuccess(result: result)

      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")

      scheduler.advance()

      updateUserInEnvironment.assertValueCount(1, "Update user in environment")

      vm.inputs.userUpdated()

      postUserUpdatedNotification.assertValues(
        [.ksr_userUpdated],
        "User updated notification posted"
      )
      notifyPresenterUserFacebookConnected.assertValueCount(1, "Notify presenter that user was updated")

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")
    }
  }

  func testFacebookConnectFlow_Error_LoginAttemptFail() {
    let error = NSError(
      domain: "facebook.com",
      code: 404,
      userInfo: [
        ErrorLocalizedTitleKey: "Facebook Login Fail",
        ErrorLocalizedDescriptionKey: "Something went wrong yo."
      ]
    )

    vm.inputs.configureWith(source: .activity)

    self.attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

    self.vm.inputs.facebookConnectButtonTapped()

    self.attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    self.showErrorAlert.assertValueCount(0, "Error alert does not emit")
    XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    self.vm.inputs.facebookLoginFail(error: error)

    self.showErrorAlert.assertValues(
      [AlertError.facebookLoginAttemptFail(error: error)],
      "Show Facebook Attempt Login error"
    )
    self.updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
    XCTAssertEqual([
      "Facebook Connect", "Connected Facebook",
      "Facebook Connect Error", "Errored Facebook Connect"
    ], self.trackingClient.events)
    XCTAssertEqual(
      [
        "activity", "activity",
        "activity", "activity"
      ],
      self.trackingClient.properties.map { $0["source"] as! String? }
    )
  }

  func testFacebookConnectFlow_Error_TokenFail() {
    let token = AccessToken(
      tokenString: "spaghetti",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["Couldn't log into Facebook."],
      ksrCode: .FacebookInvalidAccessToken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: .activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues(
        [AlertError.facebookTokenFail],
        "Show Facebook token fail error"
      )
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual([
        "Facebook Connect", "Connected Facebook",
        "Facebook Connect Error", "Errored Facebook Connect"
      ], self.trackingClient.events)
      XCTAssertEqual(
        [
          "activity", "activity",
          "activity", "activity"
        ],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )
    }
  }

  func testFacebookConnectFlow_Error_AccountTaken() {
    let token = AccessToken(
      tokenString: "spaghetti",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["This Facebook account is already linked to another Kickstarter user."],
      ksrCode: .FacebookConnectAccountTaken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: .activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues(
        [AlertError.facebookConnectAccountTaken(envelope: error)],
        "Show Facebook account taken error"
      )
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual([
        "Facebook Connect", "Connected Facebook",
        "Facebook Connect Error", "Errored Facebook Connect"
      ], self.trackingClient.events)
      XCTAssertEqual(
        [
          "activity", "activity",
          "activity", "activity"
        ],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )
    }
  }

  func testFacebookConnectFlow_Error_EmailTaken() {
    let token = AccessToken(
      tokenString: "spaghetti",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: [
        "The email associated with this Facebook account is already registered to another Kickstarter user."
      ],
      ksrCode: .FacebookConnectEmailTaken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: .activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues(
        [AlertError.facebookConnectEmailTaken(envelope: error)],
        "Show Facebook account taken error"
      )
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual([
        "Facebook Connect", "Connected Facebook",
        "Facebook Connect Error", "Errored Facebook Connect"
      ], self.trackingClient.events)
      XCTAssertEqual(
        [
          "activity", "activity",
          "activity", "activity"
        ],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )
    }
  }

  func testFacebookConnectFlow_Error_Generic() {
    let token = AccessToken(
      tokenString: "12344566",
      permissions: [],
      declinedPermissions: [],
      expiredPermissions: [],
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date(),
      dataAccessExpirationDate: Date()
    )

    let result = LoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: [],
      declinedPermissions: []
    )

    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: .activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues(
        [AlertError.genericFacebookError(envelope: error)],
        "Show Facebook account taken error"
      )
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual([
        "Facebook Connect", "Connected Facebook",
        "Facebook Connect Error", "Errored Facebook Connect"
      ], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity", "activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )
    }
  }
}
