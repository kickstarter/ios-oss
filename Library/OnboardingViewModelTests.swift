import Combine
@testable import KsApi
@testable import Library
import XCTest

final class OnboardingViewModelTest: XCTestCase {
  // MARK: Properties

  private var viewModel: OnboardingViewModel!

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.viewModel = OnboardingViewModel(with: Bundle(for: type(of: self)))
  }

  func testOnboardingItems_AreReturned_OnInit() {
    XCTAssertEqual(self.viewModel.onboardingItems.count, 5)
    XCTAssertTrue(self.viewModel.onboardingItems.contains(where: { $0.type == .welcome }))
    XCTAssertTrue(self.viewModel.onboardingItems.contains(where: { $0.type == .saveProjects }))
    XCTAssertTrue(self.viewModel.onboardingItems.contains(where: { $0.type == .enableNotifications }))
    XCTAssertTrue(self.viewModel.onboardingItems.contains(where: { $0.type == .allowTracking }))
    XCTAssertTrue(self.viewModel.onboardingItems.contains(where: { $0.type == .loginSignUp }))
  }

  func testTriggerPushNotificationPopup_IsCalled_OnGetNotifiedTapped() throws {
    var cancellables: [AnyCancellable] = []

    let expectation = expectation(description: "Waiting for action to be performed")
    var triggeredPushNotificationPopup = false
    self.viewModel.triggerPushNotificationPermissionPopup
      .sink { () in
        triggeredPushNotificationPopup = true
        expectation.fulfill()
      }
      .store(in: &cancellables)

    self.viewModel.getNotifiedTapped()
    waitForExpectations(timeout: 0.1)

    XCTAssertTrue(triggeredPushNotificationPopup)
  }

  func testAppTrackingTransparencyPopup_IsCalled_OnAllowTrackingTapped() throws {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = true
    appTrackingTransparency.shouldRequestAuthStatus = true

    withEnvironment(
      appTrackingTransparency: appTrackingTransparency
    ) {
      var cancellables: [AnyCancellable] = []

      let expectation = expectation(description: "Waiting for action to be performed")
      var triggeredPAppTrackingTransparencyPopup = false
      self.viewModel.triggerAppTrackingTransparencyPopup
        .sink { () in
          triggeredPAppTrackingTransparencyPopup = true
          expectation.fulfill()
        }
        .store(in: &cancellables)

      self.viewModel.allowTrackingTapped()
      waitForExpectations(timeout: 0.1)

      XCTAssertTrue(triggeredPAppTrackingTransparencyPopup)
    }
  }

  func testGoToLoginSignup_IsCalled_OnGoToLoginSignupTapped() throws {
    var cancellables: [AnyCancellable] = []

    let expectation = expectation(description: "Waiting for action to be performed")
    var loginIntent: LoginIntent?
    self.viewModel.goToLoginSignup
      .sink { intent in
        loginIntent = intent
        expectation.fulfill()
      }
      .store(in: &cancellables)

    self.viewModel.goToLoginSignupTapped()
    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(loginIntent, .onboarding)
  }
}
