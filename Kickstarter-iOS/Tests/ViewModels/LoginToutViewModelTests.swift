import XCTest
@testable import Kickstarter_iOS
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
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
}
