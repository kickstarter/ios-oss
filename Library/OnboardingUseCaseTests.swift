@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class OnboardingUseCaseTests: TestCase {
  var useCase: OnboardingUseCase!

  let onboardingItems = TestObserver<[OnboardingItem], Never>()
  let triggerAppTrackingTransparencyDialog = TestObserver<Void, Never>()
  let didCompletePushNotificationSystemDialog = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.useCase = OnboardingUseCase(for: Bundle(for: type(of: self)))

    self.useCase.uiOutputs.onboardingItems.start(self.onboardingItems.observer)
    self.useCase.outputs.triggerAppTrackingTransparencyDialog
      .observe(self.triggerAppTrackingTransparencyDialog.observer)
    self.useCase.outputs.didCompletePushNotificationSystemDialog
      .observe(self.didCompletePushNotificationSystemDialog.observer)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testUseCase_onboardingItems_EmitsAListOfAll5OboardingItemTypes_Once() {
    self.onboardingItems.assertValueCount(1)

    XCTAssertEqual(self.onboardingItems.lastValue?.count, 5)
  }

  func testUseCase_didCompletePushNotificationSystemDialog_Emits_WhenNotAuthorized() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.didCompletePushNotificationSystemDialog.assertDidNotEmitValue()

      self.useCase.uiInputs.getNotifiedTapped()

      self.didCompletePushNotificationSystemDialog.assertValueCount(1)
    }
  }

  func testUseCase_didCompletePushNotificationSystemDialog_DoesNotEmit_WhenAlreadyAuthorized() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.didCompletePushNotificationSystemDialog.assertDidNotEmitValue()

      self.useCase.uiInputs.getNotifiedTapped()

      self.didCompletePushNotificationSystemDialog.assertDidNotEmitValue()
    }
  }

  func testUseCase_completedAllowTrackingRequest_SetsAdvertisingID_WhenShouldRequestAuthStatus_isTrue() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      self.triggerAppTrackingTransparencyDialog.assertValueCount(0)

      XCTAssertNil(appTrackingTransparency.advertisingIdentifier)

      self.useCase.uiInputs.allowTrackingTapped()

      self.triggerAppTrackingTransparencyDialog.assertValueCount(1)
    }
  }
}
