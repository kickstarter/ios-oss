import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FeatureFlagToolsViewModelTests: TestCase {
  private let vm: FeatureFlagToolsViewModelType = FeatureFlagToolsViewModel()

  private let postNotificationName = TestObserver<Notification.Name, Never>()
  private let updateConfigWithFeatures = TestObserver<Features, Never>()
  private let reloadWithDataFeatures = TestObserver<[Features], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.postNotification.map(\.name).observe(self.postNotificationName.observer)
    self.vm.outputs.updateConfigWithFeatures.observe(self.updateConfigWithFeatures.observer)
    self.vm.outputs.reloadWithData.observe(self.reloadWithDataFeatures.observer)
  }

  func testDataIsSortedAlphabetically() {
    let featuresArray = Feature.allCases.map { $0.rawValue }
    let sortedClientFeatures = featuresArray.sorted().map { [$0: true] }
    let configFeatures = featuresArray.reduce(into: [String: Bool]()) { $0[$1] = true }

    let mockConfig = Config.template
      |> \.features .~ configFeatures

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValue(sortedClientFeatures)
    }
  }

  func testFeatureFlagTools_LoadsWithFeatureFlags() {
    let featureName = Feature.allCases.first?.rawValue ?? ""
    let mockConfig = Config.template
      |> \.features .~ [featureName: true]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        [
          [featureName: true]
        ]
      ])
    }
  }

  func testFeatureFlagTools_LoadsWithoutRecognizedFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ ["some_unknown_feature": false]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[]], "Does NOT emit unknown features")
    }
  }

  func testFeatureEnabledFromDictionaries_UnknownFeatures() {
    let featureEnabled = featureEnabledFromDictionaries([["some_unknown_feature": false]])

    XCTAssertTrue(featureEnabled.isEmpty, "Unknown features do not produce Feature enums")
  }

  func testFeatureEnabledFromDictionaries_KnownFeatures() {
    let featureEnabled = featureEnabledFromDictionaries([[
      "ios_braze": false,
      "ios_segment": false
    ]])

    XCTAssertFalse(featureEnabled.isEmpty, "Known features produce Feature enums")
  }

  func testUpdateFeatureFlagEnabledValue() {
    let originalFeatures = Feature.allCases.map { $0.rawValue }
      .reduce(into: [String: Bool]()) { $0[$1] = true }
    let expectedFeatures = Feature.allCases.map { $0.rawValue }.reduce(into: [String: Bool]()) {
      if $1 == Feature.allCases.first?.rawValue ?? "" {
        return $0[$1] = false
      }
      return $0[$1] = true
    }

    let mockConfig = Config.template
      |> \.features .~ originalFeatures

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        Feature.allCases.map { $0.rawValue }.map { [$0: true] }
      ])

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.updateConfigWithFeatures.assertValues([], "Doesn't update when the enabled value is the same.")

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: false)

      self.updateConfigWithFeatures.assertValues([expectedFeatures])
    }

    let updatedConfig = Config.template
      |> \.features .~ expectedFeatures

    withEnvironment(config: updatedConfig) {
      self.vm.inputs.didUpdateConfig()

      self.scheduler.run()

      self.reloadWithDataFeatures.assertValues([
        Feature.allCases.map { $0.rawValue }.map { [$0: true] },
        Feature.allCases.map { $0.rawValue }.map {
          if $0 == Feature.allCases.first?.rawValue ?? "" {
            return [$0: false]
          }
          return [$0: true]
        }
      ])
    }
  }

  func testUpdateConfig_UnknownFeatures() {
    let mockConfig = Config.template
      |> \.features .~ ["some_unknown_feature": false]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([[]])

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.updateConfigWithFeatures.assertValues([], "Doesn't update when the enabled value is the same.")

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: false)

      self.updateConfigWithFeatures.assertValues([])
    }
  }

  func testPostNotification() {
    let originalFeatures = Feature.allCases.map { $0.rawValue }
      .reduce(into: [String: Bool]()) { $0[$1] = true }

    let mockConfig = Config.template
      |> \.features .~ originalFeatures

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: false)

      self.updateConfigWithFeatures.assertValueCount(1)

      self.vm.inputs.didUpdateConfig()

      self.postNotificationName.assertValues([.ksr_configUpdated])
    }
  }
}
