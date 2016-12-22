import XCTest
import ReactiveSwift
import UIKit.UIActivity
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import Library
@testable import FBSDKLoginKit

  // swiftlint:disable type_name
final class FindFriendsFacebookConnectCellViewModelTests: TestCase {
  // swiftlint: enable type_name
  let vm: FindFriendsFacebookConnectCellViewModelType = FindFriendsFacebookConnectCellViewModel()

  let attemptFacebookLogin = TestObserver<(), NoError>()
  let isLoading = TestObserver<Bool, NoError>()
  let notifyPresenterToDismissHeader = TestObserver<(), NoError>()
  let notifyPresenterUserFacebookConnected = TestObserver<(), NoError>()
  let postUserUpdatedNotification = TestObserver<String, NoError>()
  let updateUserInEnvironment = TestObserver<User, NoError>()
  let showErrorAlert = TestObserver<AlertError, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.attemptFacebookLogin.observe(attemptFacebookLogin.observer)
    vm.outputs.isLoading.observe(isLoading.observer)
    vm.outputs.notifyDelegateToDismissHeader.observe(notifyPresenterToDismissHeader.observer)
    vm.outputs.notifyDelegateUserFacebookConnected.observe(notifyPresenterUserFacebookConnected.observer)
    vm.outputs.postUserUpdatedNotification.map { $0.name.rawValue }.observe(postUserUpdatedNotification.observer)
    vm.outputs.updateUserInEnvironment.observe(updateUserInEnvironment.observer)
    vm.outputs.showErrorAlert.observe(showErrorAlert.observer)
  }

  func testDismissal() {
    vm.inputs.configureWith(source: FriendsSource.activity)

    notifyPresenterToDismissHeader.assertValueCount(0)

    vm.inputs.closeButtonTapped()

    notifyPresenterToDismissHeader.assertValueCount(1)

    XCTAssertEqual(["Close Facebook Connect"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })
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
    )

    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook Login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook Connect emitted")
      XCTAssertEqual(["Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      // FIXME
      //vm.inputs.facebookLoginSuccess(result: result)

      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")

      scheduler.advance()

      updateUserInEnvironment.assertValueCount(1, "Update user in environment")

      vm.inputs.userUpdated()

      postUserUpdatedNotification.assertValues([CurrentUserNotifications.userUpdated],
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

    vm.inputs.configureWith(source: FriendsSource.activity)

    attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

    vm.inputs.facebookConnectButtonTapped()

    attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
    showErrorAlert.assertValueCount(0, "Error alert does not emit")
    XCTAssertEqual(["Facebook Connect"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.facebookLoginFail(error: error)

    self.showErrorAlert.assertValues([AlertError.facebookLoginAttemptFail(error: error)],
                                     "Show Facebook Attempt Login error")
    updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
    XCTAssertEqual(["Facebook Connect", "Facebook Connect Error"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })
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
    )

    let error = ErrorEnvelope(
      errorMessages: ["Couldn't log into Facebook."],
      ksrCode: .FacebookInvalidAccessToken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      // FIXME
//      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.facebookTokenFail],
                                       "Show Facebook token fail error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Facebook Connect Error"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity"],
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
    )

    let error = ErrorEnvelope(
      errorMessages: ["This Facebook account is already linked to another Kickstarter user."],
      ksrCode: .FacebookConnectAccountTaken,
      httpCode: 403,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      // FIXME
//      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.facebookConnectAccountTaken(envelope: error)],
                                       "Show Facebook account taken error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Facebook Connect Error"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity"],
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
      vm.inputs.configureWith(source: FriendsSource.activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      // FIXME
//      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.facebookConnectEmailTaken(envelope: error)],
                                       "Show Facebook account taken error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Facebook Connect Error"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity"],
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
    )

    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(facebookConnectError: error)) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      attemptFacebookLogin.assertValueCount(0, "Attempt Facebook login does not emit")

      vm.inputs.facebookConnectButtonTapped()

      attemptFacebookLogin.assertValueCount(1, "Attempt Facebook login emitted")
      XCTAssertEqual(["Facebook Connect"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      // FIXME
//      vm.inputs.facebookLoginSuccess(result: result)

      self.showErrorAlert.assertValueCount(0, "Error alert does not emit")

      scheduler.advance()

      self.showErrorAlert.assertValues([AlertError.genericFacebookError(envelope: error)],
                                       "Show Facebook account taken error")
      updateUserInEnvironment.assertValueCount(0, "Update user does not emit")
      XCTAssertEqual(["Facebook Connect", "Facebook Connect Error"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }
}
