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

  func testTrackingGetStartedButtonTapped() {
    XCTAssertEqual(self.optimizelyClient.trackedEventKey, nil)

    self.viewModel.inputs.ctaButtonTapped()

    XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Get Started Button Clicked")
    XCTAssertEqual(self.trackingClient.events, ["Onboarding Get Started Button Clicked"])
    XCTAssertEqual(
      self.trackingClient.properties(forKey: "context_location"),
      ["landing_page"]
    )
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

  func testCards_Variant1() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.viewModel.inputs.viewDidLoad()

      self.landingPageCards.assertValue(LandingPageCardType.statsCards)
    }
  }

  func testCards_Variant2() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant2.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.viewModel.inputs.viewDidLoad()

      self.landingPageCards.assertValue(LandingPageCardType.howToCards)
    }
  }

  func testCards_Control() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.control.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.viewModel.inputs.viewDidLoad()

      self.landingPageCards.assertDidNotEmitValue()
    }
  }

  func testNumberOfPages() {
    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant2.rawValue]

    withEnvironment(currentUser: nil, optimizelyClient: optimizelyClient) {
      self.viewModel.inputs.viewDidLoad()

      let cards = LandingPageCardType.howToCards
      self.numberOfPages.assertValue(cards.count)
    }
  }
}
