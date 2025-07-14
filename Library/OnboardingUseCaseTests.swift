@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class OnboardingUseCaseTests: XCTestCase {
  var useCase: OnboardingUseCase!

  let onboardingItems = TestObserver<[OnboardingItem], Never>()
  let goToLoginSignup = TestObserver<LoginIntent, Never>()
  let completedGetNotifiedRequest = TestObserver<Void, Never>()
  let completedAllowTrackingRequest = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.useCase = OnboardingUseCase(for: Bundle(for: type(of: self)))

    self.useCase.uiOutputs.onboardingItems.start(self.onboardingItems.observer)
    self.useCase.uiOutputs.goToLoginSignup.observe(self.goToLoginSignup.observer)
    self.useCase.outputs.completedGetNotifiedRequest.observe(self.completedGetNotifiedRequest.observer)
    self.useCase.outputs.triggerAppTrackingTransparencyPopup
      .observe(self.completedAllowTrackingRequest.observer)
  }

  func testUseCase_onboardingItems_EmitsAListOfAll5OboardingItemTypes_Once() {
    self.onboardingItems.assertValueCount(1)

    XCTAssertEqual(self.onboardingItems.lastValue?.count, 5)
  }

  func testUseCase_completedGetNotifiedRequest_Emits_WhenHasAuthorizedPermission() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.completedGetNotifiedRequest.assertValueCount(0)

      self.useCase.uiInputs.getNotifiedTapped()

      self.completedGetNotifiedRequest.assertValueCount(1)
    }
  }

  func testUseCase_completedGetNotifiedRequest_Emits_HasDeniedAuthorization() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.completedGetNotifiedRequest.assertValueCount(0)

      self.useCase.uiInputs.getNotifiedTapped()

      self.completedGetNotifiedRequest.assertValueCount(1)
    }
  }

  func testUseCase_completedAllowTrackingRequest_SetsAdvertisingID_WhenShouldRequestAuthStatus_isTrue() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.completedAllowTrackingRequest.assertValueCount(0)

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)

      self.useCase.uiInputs.allowTrackingTapped()

      self.completedAllowTrackingRequest.assertValueCount(1)
    }
  }

  func testUseCase_GoesToLoginSignup_AfterLoginSignupTapped() {
    self.goToLoginSignup.assertDidNotEmitValue()

    self.useCase.uiInputs.goToLoginSignupTapped()

    self.goToLoginSignup.assertDidEmitValue()
  }
}
