import XCTest
@testable import Kickstarter_iOS
@testable import ReactiveCocoa
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import Library

final class LoginToutViewModelTests: XCTestCase {

  func testKoala_whenLoginIntentBeforeViewAppears() {
    let trackingClient = MockTrackingClient()
    let koala = Koala(client: trackingClient)

    withEnvironment(koala: koala) {
      let vm: LoginToutViewModelType = LoginToutViewModel()

      vm.inputs.loginIntent(LoginIntent.Activity)
      vm.inputs.viewDidAppear()

      XCTAssertEqual(["Application Login or Signup"], trackingClient.events)

      vm.inputs.viewDidAppear()

      XCTAssertEqual(["Application Login or Signup"], trackingClient.events)
    }
  }

  func testKoala_whenViewAppearsBeforeLoginIntent() {
    let trackingClient = MockTrackingClient()
    let koala = Koala(client: trackingClient)

    withEnvironment(koala: koala) {
      let vm: LoginToutViewModelType = LoginToutViewModel()

      vm.inputs.viewDidAppear()
      vm.inputs.loginIntent(LoginIntent.Activity)

      XCTAssertEqual(["Application Login or Signup"], trackingClient.events)
    }
  }

  func testStartLogin() {
    let vm: LoginToutViewModelType = LoginToutViewModel()

    let startLogin = TestObserver<(), NoError>()
    vm.outputs.startLogin.observe(startLogin.observer)

    vm.inputs.loginButtonPressed()

    startLogin.assertValueCount(1)
  }

  func testStartSignup() {
    let vm: LoginToutViewModelType = LoginToutViewModel()

    let startSignup = TestObserver<(), NoError>()
    vm.outputs.startSignup.observe(startSignup.observer)

    vm.inputs.signupButtonPressed()

    startSignup.assertValueCount(1)
  }

  func testShowHelpSheet() {
    let vm: LoginToutViewModelType = LoginToutViewModel()

    let showHelpActionSheet = TestObserver<[HelpType], NoError>()
    vm.outputs.showHelpActionSheet
      .map { actions in actions.map { title, helpType in helpType} }
      .observe(showHelpActionSheet.observer)

    vm.inputs.helpButtonPressed()

    showHelpActionSheet.assertValues([HelpType.allValues])
  }

  func testShowHelpType() {
    let vm: LoginToutViewModelType = LoginToutViewModel()

    let showHelp = TestObserver<HelpType, NoError>()
    vm.outputs.showHelp.observe(showHelp.observer)

    vm.inputs.helpTypeButtonPressed(HelpType.Contact)

    showHelp.assertValue(HelpType.Contact, "Show help emitted with type .Contact")

    vm.inputs.helpTypeButtonPressed(HelpType.Cookie)

    showHelp.assertValues([HelpType.Contact, HelpType.Cookie], "Show help emitted with type .Cookie")

    vm.inputs.helpTypeButtonPressed(HelpType.HowItWorks)

    showHelp.assertValues([HelpType.Contact, HelpType.Cookie, HelpType.HowItWorks], "Show help emitted with type .HowItWorks")

    vm.inputs.helpTypeButtonPressed(HelpType.Privacy)

    showHelp.assertValues([HelpType.Contact, HelpType.Cookie, HelpType.HowItWorks, HelpType.Privacy], "Show help emitted with type .Privacy")

    vm.inputs.helpTypeButtonPressed(HelpType.Terms)

    showHelp.assertValues([HelpType.Contact, HelpType.Cookie, HelpType.HowItWorks, HelpType.Privacy, HelpType.Terms], "Show help emitted with type .Terms")
  }
}
