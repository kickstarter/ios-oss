import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FeatureFlagToolsViewModelTests: TestCase {
  private let vm: FeatureFlagToolsViewModelType = FeatureFlagToolsViewModel()

  private let updateConfigWithFeatures = TestObserver<Features, Never>()
  private let reloadWithDataFeatures = TestObserver<[Feature], Never>()
  private let reloadWithDataEnabledValues = TestObserver<[Bool], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.updateConfigWithFeatures.observe(self.updateConfigWithFeatures.observer)
    self.vm.outputs.reloadWithData.map { $0.map { $0.0 } }.observe(self.reloadWithDataFeatures.observer)
    self.vm.outputs.reloadWithData.map { $0.map { $0.1 } }.observe(self.reloadWithDataEnabledValues.observer)
  }

  func testDataIsSortedAlphabetically_When_Sorted() {
    let mockConfig = Config.template
      |> \.features .~ [
        Feature.nativeCheckout.rawValue: false,
        Feature.nativeCheckoutPledgeView.rawValue: true
      ]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[Feature.nativeCheckout, Feature.nativeCheckoutPledgeView]])
      self.reloadWithDataEnabledValues.assertValues([[false, true]])
    }
  }

  func testDataIsSortedAlphabetically_When_Unsorted() {
    let mockConfig = Config.template
      |> \.features .~ [
        Feature.nativeCheckoutPledgeView.rawValue: true,
        Feature.nativeCheckout.rawValue: false
      ]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[Feature.nativeCheckout, Feature.nativeCheckoutPledgeView]])
      self.reloadWithDataEnabledValues.assertValues([[false, true]])
    }
  }

  func testFeatureFlagTools_LoadsWithFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.nativeCheckout.rawValue: true]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[Feature.nativeCheckout]])
      self.reloadWithDataEnabledValues.assertValues([[true]])
    }
  }

  func testFeatureFlagTools_LoadsWithoutRecognizedFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ ["some_unknown_feature": false]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[]], "Does not display unrecognized features.")
      self.reloadWithDataEnabledValues.assertValues([[]], "Does not display unrecognized features.")
    }
  }

  func testUpdateFeatureFlagEnabledValue() {
    let originalFeatures = [
      Feature.nativeCheckoutPledgeView.rawValue: true,
      Feature.nativeCheckout.rawValue: true
    ]

    let expectedFeatures = [
      Feature.nativeCheckout.rawValue: true,
      Feature.nativeCheckoutPledgeView.rawValue: false
    ]

    let mockConfig = Config.template
      |> \.features .~ originalFeatures

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[Feature.nativeCheckout, Feature.nativeCheckoutPledgeView]])
      self.reloadWithDataEnabledValues.assertValues([[true, true]])

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.updateConfigWithFeatures.assertValues([], "Doesn't update when the enabled value is the same.")

      self.vm.inputs.setFeatureAtIndexEnabled(index: 1, isEnabled: false)

      self.updateConfigWithFeatures.assertValues([expectedFeatures])
    }

    let updatedConfig = Config.template
      |> \.features .~ expectedFeatures

    withEnvironment(config: updatedConfig) {
      self.vm.inputs.didUpdateConfig()

      scheduler.run()

      self.reloadWithDataFeatures.assertValues([
        [Feature.nativeCheckout, Feature.nativeCheckoutPledgeView],
        [Feature.nativeCheckout, Feature.nativeCheckoutPledgeView]
      ])
      self.reloadWithDataEnabledValues.assertValues([[true, true], [true, false]])
    }
  }
}
