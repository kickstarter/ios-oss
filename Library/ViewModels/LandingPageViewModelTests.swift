@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class LandingPageViewModelTests: TestCase {

  fileprivate let landingPageCards = TestObserver<[LandingPageCardType], Never>()
  fileprivate let viewModel: LandingPageViewModelType = LandingPageViewModel()

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.landingPageCards.observe(self.landingPageCards.observer)
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
}
