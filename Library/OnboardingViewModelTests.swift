import AppTrackingTransparency
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

    self.viewModel.outputs.triggerAppTrackingTransparencyPopup
      .observe(self.appTrackingTransparencyDialogObserver.observer)
    self.viewModel.outputs.didCompletePushNotificationSystemDialog
      .observe(self.didCompletePushNotificationSystemDialog.observer)
  }

  func testOnboardingItems_AreReturned_OnInit() {
    let expectation = expectation(description: "onboardingItems loaded")

    self.viewModel.outputs.onboardingItems.startWithResult { result in
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
      self.viewModel.inputs.getNotifiedTapped()

      XCTAssertEqual(self.didCompletePushNotificationSystemDialog.values.count, 1)
    }
  }

  func testGetNotifiedTapped_DoesNotTriggerDialog_WhenAlreadyAuthorized() {
    MockPushRegistration.hasAuthorizedNotificationsProducer = .init(value: true)
    MockPushRegistration.registerProducer = .init(value: false)

    withEnvironment(pushRegistrationType: MockPushRegistration.self) {
      self.viewModel.inputs.getNotifiedTapped()

      XCTAssertEqual(self.didCompletePushNotificationSystemDialog.values.count, 0)
    }
  }

  func testAppTrackingTransparencyPopup_IsCalled_OnAllowTrackingTapped() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(appTrackingTransparency: appTrackingTransparency) {
      self.viewModel.inputs.allowTrackingTapped()

      XCTAssertEqual(self.appTrackingTransparencyDialogObserver.values.count, 1)
    }
  }

  func testAllowTrackingTapped_DoesNotTrigger_WhenNotRequired() {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.shouldRequestAuthStatus = false

    withEnvironment(appTrackingTransparency: appTrackingTransparency) {
      self.viewModel.inputs.allowTrackingTapped()

      XCTAssertEqual(self.appTrackingTransparencyDialogObserver.values.count, 0)
    }
  }

  func testOnAppear_FiresPageViewedAnalyticsEvents() {
    self.viewModel.inputs.onAppear()

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    XCTAssertEqual("onboarding", self.segmentTrackingClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("welcome", self.segmentTrackingClient.properties.last?["context_section"] as? String)
  }

  func testDidCompleteAppTrackingDialog_FiresAnalyticsEvent() {
    self.viewModel.inputs.didCompleteAppTrackingDialog(with: .authorized)

    XCTAssertEqual(["CTA Clicked"], self.segmentTrackingClient.events)
    XCTAssertEqual("onboarding", self.segmentTrackingClient.properties.last?["context_page"] as? String)
    XCTAssertEqual(
      "activity_tracking_prompt",
      self.segmentTrackingClient.properties.last?["context_section"] as? String
    )
    XCTAssertEqual("allow", self.segmentTrackingClient.properties.last?["context_cta"] as? String)

    self.viewModel.inputs.didCompleteAppTrackingDialog(with: .denied)

    XCTAssertEqual(["CTA Clicked", "CTA Clicked"], self.segmentTrackingClient.events)
    XCTAssertEqual("onboarding", self.segmentTrackingClient.properties.last?["context_page"] as? String)
    XCTAssertEqual(
      "activity_tracking_prompt",
      self.segmentTrackingClient.properties.last?["context_section"] as? String
    )
    XCTAssertEqual("deny", self.segmentTrackingClient.properties.last?["context_cta"] as? String)
  }

  func testGoToLoginSignupTapped_FiresAnalyticsEvents() {
    self.viewModel.inputs.goToLoginSignupTapped()

    /// Two events should be fired. One that tracks login/signup tapped and one that tracks that the onboarding flow was closed.
    /// We're asserting on both events (that will be the last two in `self.segmentTrackingClient.properties`).

    XCTAssertEqual(["CTA Clicked", "CTA Clicked"], self.segmentTrackingClient.events)

    /// Signup/login tapped assertions.
    XCTAssertEqual(
      "onboarding",
      self.segmentTrackingClient
        .properties[self.segmentTrackingClient.properties.count - 2]["context_page"] as? String
    )
    XCTAssertEqual(
      "signup_login",
      self.segmentTrackingClient
        .properties[self.segmentTrackingClient.properties.count - 2]["context_section"] as? String
    )
    XCTAssertEqual(
      "signup_login",
      self.segmentTrackingClient
        .properties[self.segmentTrackingClient.properties.count - 2]["context_cta"] as? String
    )

    /// Close assertions.
    XCTAssertEqual("onboarding", self.segmentTrackingClient.properties.last?["context_page"] as? String)
    XCTAssertNil(self.segmentTrackingClient.properties.last?["context_section"] as? String)
    XCTAssertEqual("close", self.segmentTrackingClient.properties.last?["context_cta"] as? String)
  }

  func testOnboardingFlowEnded_FiresAnalyticsEvent() {
    self.viewModel.inputs.onboardingFlowEnded()

    XCTAssertEqual("onboarding", self.segmentTrackingClient.properties.last?["context_page"] as? String)
    XCTAssertNil(self.segmentTrackingClient.properties.last?["context_section"] as? String)
    XCTAssertEqual("close", self.segmentTrackingClient.properties.last?["context_cta"] as? String)
  }

  func testGoToNextItemTapped_FiresAnalyticsEvents() {
    let onboardingItem = OnboardingItem(title: "test", subtitle: "test", type: .saveProjects)

    self.viewModel.inputs.goToNextItemTapped(item: onboardingItem)

    /// Two events should be fired. One that tracks when 'next' tapped and one that tracks that the next onboarding flow item has been viewed..
    /// We're asserting on both events (that will be the last two in `self.segmentTrackingClient.properties`).

    XCTAssertEqual(["Page Viewed", "CTA Clicked"], self.segmentTrackingClient.events)

    /// Page viewed.
    XCTAssertEqual(
      "onboarding",
      self.segmentTrackingClient
        .properties[self.segmentTrackingClient.properties.count - 2]["context_page"] as? String
    )
    XCTAssertEqual(
      "save_projects",
      self.segmentTrackingClient
        .properties[self.segmentTrackingClient.properties.count - 2]["context_section"] as? String
    )

    /// Next tapped assertions.
    XCTAssertEqual("onboarding", self.segmentTrackingClient.properties.last?["context_page"] as? String)
    XCTAssertEqual("save_projects", self.segmentTrackingClient.properties.last?["context_section"] as? String)
    XCTAssertEqual("next", self.segmentTrackingClient.properties.last?["context_cta"] as? String)
  }
}
