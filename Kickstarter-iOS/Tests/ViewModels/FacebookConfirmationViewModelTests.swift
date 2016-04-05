import XCTest
import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Kickstarter_iOS
@testable import Library

final class FacebookConfirmationViewModelTests: TestCase {
  var vm: FacebookConfirmationViewModelType!

  override func setUp() {
    super.setUp()
    self.vm = FacebookConfirmationViewModel()
  }

  func testDisplayEmail_whenViewWillAppear() {
    let displayEmail = TestObserver<String, NoError>()
    vm.outputs.displayEmail.observe(displayEmail.observer)

    vm.inputs.email("kittens@kickstarter.com")

    displayEmail.assertDidNotEmitValue("Email does not display")

    vm.inputs.viewWillAppear()

    displayEmail.assertValues(["kittens@kickstarter.com"], "Display email")

    XCTAssertEqual(["Facebook Confirm"], trackingClient.events)
  }

  func testNewsletterToggle() {
    let sendNewsletters = TestObserver<Bool, NoError>()
    vm.outputs.sendNewsletters.observe(sendNewsletters.observer)

    sendNewsletters.assertDidNotEmitValue("Newsletter toggle does not emit")

    vm.inputs.viewWillAppear()

    sendNewsletters.assertValues([true], "Newsletter toggle is off")
    XCTAssertEqual(["Facebook Confirm"], trackingClient.events, "Newsletter toggle is not tracked on intital state")

    vm.inputs.sendNewslettersToggled(false)

    sendNewsletters.assertValues([true, false], "Newsletter toggle is on")
    XCTAssertEqual(["Facebook Confirm", "Signup Newsletter Toggle"], trackingClient.events, "Newsletter toggle is tracked")
    XCTAssertEqual(false, trackingClient.properties.last!["send_newsletters"] as? Bool)

    vm.inputs.sendNewslettersToggled(true)

    sendNewsletters.assertValues([true, false, true], "Newsletter toggle is off")
    XCTAssertEqual(["Facebook Confirm", "Signup Newsletter Toggle", "Signup Newsletter Toggle"], trackingClient.events, "Newsletter toggle is tracked")
    XCTAssertEqual(true, trackingClient.properties.last!["send_newsletters"] as? Bool)

    // todo: test German double-opt-in
  }

  func testCreateNewAccount_withoutNewsletterToggle() {
    let newAccountSuccess = TestObserver<(), NoError>()
    vm.outputs.newAccountSuccess.observe(newAccountSuccess.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.facebookToken("PuRrrrrrr3848")
    vm.inputs.createAccountButtonPressed()

    newAccountSuccess.assertValueCount(1, "Account successfully created")
    XCTAssertEqual(["Facebook Confirm", "New User"], trackingClient.events)
  }

  func testCreateNewAccount_withNewsletterToggle() {
    let newAccountSuccess = TestObserver<(), NoError>()
    vm.outputs.newAccountSuccess.observe(newAccountSuccess.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.facebookToken("PuRrrrrrr3848")
    vm.inputs.sendNewslettersToggled(true)
    vm.inputs.createAccountButtonPressed()

    newAccountSuccess.assertValueCount(1, "Account successfully created")
    XCTAssertEqual(["Facebook Confirm", "Signup Newsletter Toggle", "New User"], trackingClient.events)
  }

  func testShowLogin() {
    let showLogin = TestObserver<(), NoError>()
    vm.outputs.showLogin.observe(showLogin.observer)

    vm.inputs.viewWillAppear()
    vm.inputs.loginButtonPressed()

    showLogin.assertValueCount(1, "Show login")
  }
}
