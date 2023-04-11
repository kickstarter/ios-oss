@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class LandingPageViewModelTests: TestCase {
  private let dismissViewController = TestObserver<(), Never>()
  private let landingPageCards = TestObserver<[LandingPageCardType], Never>()
  private let numberOfPages = TestObserver<Int, Never>()
  private let viewModel: LandingPageViewModelType = LandingPageViewModel()

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.viewModel.outputs.landingPageCards.observe(self.landingPageCards.observer)
    self.viewModel.outputs.numberOfPages.observe(self.numberOfPages.observer)
  }

  func testDismissViewController_OnButtonTap() {
    self.dismissViewController.assertDidNotEmitValue()

    self.viewModel.inputs.ctaButtonTapped()

    self.dismissViewController.assertValueCount(1)
  }

  func testUserDefaultsUpdates_OnViewDidLoad() {
    let userDefaults = MockKeyValueStore()

    withEnvironment(currentUser: nil, userDefaults: userDefaults) {
      let hasSeenLandingPageKey = AppKeys.hasSeenLandingPage.rawValue

      XCTAssertFalse(userDefaults.bool(forKey: hasSeenLandingPageKey))

      self.viewModel.inputs.viewDidLoad()

      XCTAssertTrue(userDefaults.bool(forKey: hasSeenLandingPageKey))
    }
  }

  func testCards() {
    withEnvironment(currentUser: nil) {
      self.viewModel.inputs.viewDidLoad()

      self.landingPageCards.assertDidNotEmitValue()
    }
  }
}
