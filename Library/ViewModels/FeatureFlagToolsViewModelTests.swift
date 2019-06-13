import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FeatureFlagToolsViewModelTests: TestCase {
  private let vm = FeatureFlagToolsViewModel()

  private let updateConfigWithFeatures = TestObserver<Features, Never>()
  private let reloadWithDataFeatures = TestObserver<[Feature], Never>()
  private let reloadWithDataEnabledValues = TestObserver<[Bool], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.updateConfigWithFeatures.observe(self.updateConfigWithFeatures.observer)
    self.vm.outputs.reloadWithData.map { $0.map { $0.0 } }.observe(self.reloadWithDataFeatures.observer)
    self.vm.outputs.reloadWithData.map { $0.map { $0.1 } }.observe(self.reloadWithDataEnabledValues.observer)
  }

  func testFeatureFlagTools_LoadsWithFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.checkout.rawValue: true]

    withEnvironment(config: mockConfig) {
      self.vm.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[Feature.checkout]])
      self.reloadWithDataEnabledValues.assertValues([[true]])
    }
  }

  func testFeatureFlagTools_LoadsWithoutRecognizedFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ ["some_unknown_feature": false]

    withEnvironment(config: mockConfig) {
      self.vm.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[]], "Does not display unrecognized features.")
      self.reloadWithDataEnabledValues.assertValues([[]], "Does not display unrecognized features.")
    }
  }

  func testUpdateFeatureFlagEnabledValue() {
    let mockConfig = Config.template
      |> \.features .~ [
        Feature.checkout.rawValue: true,
        "some_unknown_feature": false
      ]

    let updatedFeatures = [Feature.checkout.rawValue: false, "some_unknown_feature": false]

    withEnvironment(config: mockConfig) {
      self.vm.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[Feature.checkout]])
      self.reloadWithDataEnabledValues.assertValues([[true]])

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.updateConfigWithFeatures.assertValues([], "Doesn't update when the enabled value is the same.")

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: false)

      self.updateConfigWithFeatures
        .assertValues(
          [updatedFeatures],
          "Updates the correct feature."
        )
    }

    let updatedConfig = Config.template
      |> \.features .~ updatedFeatures

    withEnvironment(config: updatedConfig) {
      self.vm.didUpdateConfig()

      scheduler.run()

      self.reloadWithDataFeatures.assertValues([[Feature.checkout], [Feature.checkout]])
      self.reloadWithDataEnabledValues.assertValues([[true], [false]])
    }
  }
}
