// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
import XCTest
import ReactiveSwift
import UIKit.UIActivity
import Prelude
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import Library
@testable import FBSDKLoginKit

  final class FindFriendsFacebookConnectCellViewModelTests: TestCase {
  // swiftlint: enable type_name
  let vm: FindFriendsFacebookConnectCellViewModelType = FindFriendsFacebookConnectCellViewModel()

  let attemptFacebookLogin = TestObserver<(), NoError>()
  let hideCloseButtonObserver = TestObserver<Bool, NoError>()
  let isLoading = TestObserver<Bool, NoError>()
  let notifyPresenterToDismissHeader = TestObserver<(), NoError>()
  let notifyPresenterUserFacebookConnected = TestObserver<(), NoError>()
  let postUserUpdatedNotification = TestObserver<Notification.Name, NoError>()
  let updateUserInEnvironment = TestObserver<User, NoError>()
  let showErrorAlert = TestObserver<AlertError, NoError>()
  let title = TestObserver<String, NoError>()
  let subtitle = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.attemptFacebookLogin.observe(attemptFacebookLogin.observer)
    vm.outputs.hideCloseButton.observe(hideCloseButtonObserver.observer)
    vm.outputs.isLoading.observe(isLoading.observer)
    vm.outputs.notifyDelegateToDismissHeader.observe(notifyPresenterToDismissHeader.observer)
    vm.outputs.notifyDelegateUserFacebookConnected.observe(notifyPresenterUserFacebookConnected.observer)
    vm.outputs.postUserUpdatedNotification.map { $0.name }
      .observe(postUserUpdatedNotification.observer)
    vm.outputs.updateUserInEnvironment.observe(updateUserInEnvironment.observer)
    vm.outputs.showErrorAlert.observe(showErrorAlert.observer)
    vm.outputs.facebookConnectCellTitle.observe(title.observer)
    vm.outputs.facebookConnectCellSubtitle.observe(subtitle.observer)
  }

  func testHideCloseButton() {
    vm.inputs.configureWith(source: .findFriends)

    self.hideCloseButtonObserver.assertValue(true)
  }

  func testShowCloseButton() {
    vm.inputs.configureWith(source: .activity)

    self.hideCloseButtonObserver.assertValue(false)
  }

  func testDismissal() {
    vm.inputs.configureWith(source: .activity)

    notifyPresenterToDismissHeader.assertValueCount(0)

    vm.inputs.closeButtonTapped()

    notifyPresenterToDismissHeader.assertValueCount(1)

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
    withEnvironment(currentUser: User.template
      |> User.lens.facebookConnected .~ true
      |> User.lens.needsFreshFacebookToken .~ true) {
        vm.inputs.configureWith(source: .activity)

        title.assertValue(Strings.Facebook_reconnect())
        subtitle.assertValue(Strings.Facebook_reconnect_description())
    }
  }

  func testFacebookConnectFlow_Success() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )!

    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: .activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook Login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook Connect emitted")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? })

      vm.inputs.facebookLoginSuccess(result: result)

      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")

      scheduler.advance()

      updateUserInEnvironment.assertValueCount(1, "Update user in environment")

      vm.inputs.userUpdated()

      postUserUpdatedNotification.assertValues([.ksr_userUpdated],
                                               "User updated notification posted")
      notifyPresenterUserFacebookConnected.assertValueCount(1, "Notify presenter that user was updated")

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")
    }
  }

  func testFacebookConnectFlow_Error_LoginAttemptFail() {
    let error = NSError(domain: "facebook.com",
                        code: 404,
                        userInfo: [
                          FBSDKErrorLocalizedTitleKey: "Facebook Login Fail",
                          FBSDKErrorLocalizedDescriptionKey: "Something went wrong yo."
      ])

    vm.inputs.configureWith(source: .activity)

    attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

    vm.inputs.facebookConnectButtonTapped()

    attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    showErrorAlert.assertValueCount(0, "Error alert does not emit")
    XCTAssertEqual(["Facebook Connect", "Connected Facebook"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.facebookLoginFail(error: error)

    self.showErrorAlert.assertValues([AlertError.facebookLoginAttemptFail(error: error)],
                                     "Show Facebook Attempt Login error")
    updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
    XCTAssertEqual(["Facebook Connect", "Connected Facebook",
                    "Facebook Connect Error", "Errored Facebook Connect"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity",
                    "activity", "activity"],
      self.trackingClient.properties.map { $0["source"] as! String? })
  }

  func testFacebookConnectFlow_Error_TokenFail() {
    let token = FBSDKAccessToken(
      tokenString: "spaghetti",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )!

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
      XCTAssertEqual(["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? })

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.facebookTokenFail],
                                       "Show Facebook token fail error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook",
                      "Facebook Connect Error", "Errored Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity",
                      "activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }

  func testFacebookConnectFlow_Error_AccountTaken() {
    let token = FBSDKAccessToken(
      tokenString: "spaghetti",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )!

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
      XCTAssertEqual(["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? })

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.facebookConnectAccountTaken(envelope: error)],
                                       "Show Facebook account taken error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook",
                      "Facebook Connect Error", "Errored Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity",
                      "activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }

  func testFacebookConnectFlow_Error_EmailTaken() {
    let token = FBSDKAccessToken(
      tokenString: "spaghetti",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )!

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
      XCTAssertEqual(["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? })

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.facebookConnectEmailTaken(envelope: error)],
                                       "Show Facebook account taken error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook",
                      "Facebook Connect Error", "Errored Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity",
                      "activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }

  func testFacebookConnectFlow_Error_Generic() {
    let token = FBSDKAccessToken(
      tokenString: "12344566",
      permissions: nil,
      declinedPermissions: nil,
      appID: "834987809",
      userID: "0000000001",
      expirationDate: Date(),
      refreshDate: Date()
    )

    let result = FBSDKLoginManagerLoginResult(
      token: token,
      isCancelled: false,
      grantedPermissions: nil,
      declinedPermissions: nil
    )!

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
      XCTAssertEqual(["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? })

      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.genericFacebookError(envelope: error)],
                                       "Show Facebook account taken error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Connected Facebook",
                      "Facebook Connect Error", "Errored Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity", "activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }
}
