@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class LandingPageViewModelTests: TestCase {

  private let dismissViewController = TestObserver<(), Never>()
  private let viewModel: LandingPageViewModelType = LandingPageViewModel()


  override func setUp() {
    super.setUp()

    self.viewModel.outputs.dismissViewController.observe(self.dismissViewController.observer)
  }

  func testDismissViewController_OnButtonTap() {
    self.dismissViewController.assertDidNotEmitValue()

    self.viewModel.inputs.ctaButtonTapped()

    self.dismissViewController.assertValueCount(1)
  }

  func testUserDefaultsUpdates_OnButtonTap() {
    let userDefaults = MockKeyValueStore()

    withEnvironment(currentUser: nil, userDefaults: userDefaults) {

      let hasSeenLandingPageKey = AppKeys.hasSeenLandingPage.rawValue
      
      XCTAssertFalse(userDefaults.bool(forKey: hasSeenLandingPageKey))

      self.viewModel.inputs.ctaButtonTapped()

      XCTAssertTrue(userDefaults.bool(forKey: hasSeenLandingPageKey))
    }
  }
}
