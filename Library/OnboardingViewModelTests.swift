import KsApi
import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class OnboardingViewModelTest: TestCase {
  // MARK: Properties

  private var viewModel: OnboardingViewModel!

  let appTrackingTransparencyDialogObserver = TestObserver<Void, Never>()
  let didCompletePushNotificationSystemDialog = TestObserver<Void, Never>()

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.viewModel = OnboardingViewModel(with: Bundle(for: type(of: self)))

    self.viewModel.triggerAppTrackingTransparencyPopup
      .observe(self.appTrackingTransparencyDialogObserver.observer)
    self.viewModel.didCompletePushNotificationSystemDialog
      .observe(self.didCompletePushNotificationSystemDialog.observer)
  }

  func testOnboardingItems_AreReturned_OnInit() {
    let expectation = expectation(description: "onboardingItems loaded")

    self.viewModel.onboardingItems.startWithResult { result in
      switch result {
      case let .success(items):
        XCTAssertEqual(items.count, 5)
        XCTAssertTrue(items.contains(where: { $0.type == .welcome }))
        XCTAssertTrue(items.contains(where: { $0.type == .saveProjects }))
        XCTAssertTrue(items.contains(where: { $0.type == .enableNotifications }))
        XCTAssertTrue(items.contains(where: { $0.type == .allowTracking }))
        XCTAssertTrue(items.contains(where: { $0.type == .loginSignUp }))
        expectation.fulfill()
      case .failure:
        XCTFail("Expected onboardingItems list to load.")
      }
    }

    waitForExpectations(timeout: 1.0)
  }

  func testTriggerPushNotificationPopup_IsCalled_OnGetNotifiedTapped() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: false)
    MockPushRegistration.registerProducer = .init(value: true)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.viewModel.getNotifiedTapped()

      XCTAssertEqual(self.didCompletePushNotificationSystemDialog.values.count, 1)
    }
  }

  func testGetNotifiedTapped_DoesNotTriggerDialog_WhenAlreadyAuthorized() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)
    MockPushRegistration.registerProducer = .init(value: false)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.viewModel.getNotifiedTapped()

      XCTAssertEqual(self.didCompletePushNotificationSystemDialog.values.count, 0)
    }
  }

  func testAppTrackingTransparencyPopup_IsCalled_OnAllowTrackingTapped() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(appTrackingTransparency: appTrackingTransparency) {
      self.viewModel.allowTrackingTapped()

      XCTAssertEqual(self.appTrackingTransparencyDialogObserver.values.count, 1)
    }
  }

  func testAllowTrackingTapped_DoesNotTrigger_WhenNotRequired() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.shouldRequestAuthStatus = false

    withEnvironment(appTrackingTransparency: appTrackingTransparency) {
      self.viewModel.allowTrackingTapped()

      XCTAssertEqual(self.appTrackingTransparencyDialogObserver.values.count, 0)
    }
  }
}
