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

  func testDataIsSortedAlphabetically_When_Sorted() {
    let mockConfig = Config.template
      |> \.features .~ [
        "a": false,
        "b": true,
        "c": true
      ]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        [
          ["a": false],
          ["b": true],
          ["c": true]
        ]
      ])
    }
  }

  func testDataIsSortedAlphabetically_When_Unsorted() {
    let mockConfig = Config.template
      |> \.features .~ [
        "c": true,
        "a": false,
        "b": true
      ]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        [
          ["a": false],
          ["b": true],
          ["c": true]
        ]
      ])
    }
  }

  func testFeatureFlagTools_LoadsWithFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ ["a": true]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        [
          ["a": true]
        ]
      ])
    }
  }

  func testFeatureFlagTools_LoadsWithoutRecognizedFeatureFlags() {
    let mockConfig = Config.template
      |> \.features .~ ["some_unknown_feature": false]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        [
          ["some_unknown_feature": false]
        ]
      ], "Does emit unknown features")
    }
  }

  func testFeatureEnabledFromDictionaries_UnkownFeatures() {
    let featureEnabled = featureEnabledFromDictionaries([["some_unknown_feature": false]])

    XCTAssertTrue(featureEnabled.isEmpty, "Unknown features do not produce Feature enums")
  }

  func testFeatureEnabledFromDictionaries_KnownFeatures() {
    let featureEnabled = featureEnabledFromDictionaries([["ios_qualtrics": false]])

    XCTAssertFalse(featureEnabled.isEmpty, "Known features produce Feature enums")
  }

  func testUpdateFeatureFlagEnabledValue() {
    let originalFeatures = [
      "a": true,
      "b": true
    ]

    let expectedFeatures = [
      "a": true,
      "b": false
    ]

    let mockConfig = Config.template
      |> \.features .~ originalFeatures

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataFeatures.assertValues([
        [
          ["a": true],
          ["b": true]
        ]
      ])

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.updateConfigWithFeatures.assertValues([], "Doesn't update when the enabled value is the same.")

      self.vm.inputs.setFeatureAtIndexEnabled(index: 1, isEnabled: false)

      self.updateConfigWithFeatures.assertValues([expectedFeatures])
    }

    let updatedConfig = Config.template
      |> \.features .~ expectedFeatures

    withEnvironment(config: updatedConfig) {
      self.vm.inputs.didUpdateConfig()

      self.scheduler.run()

      self.reloadWithDataFeatures.assertValues([
        [
          ["a": true],
          ["b": true]
        ],
        [
          ["a": true],
          ["b": false]
        ]
      ])
    }
  }

  func testPostNotification() {
    let mockConfig = Config.template
      |> \.features .~ [
        "a": true,
        "b": true
      ]

    withEnvironment(config: mockConfig) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: false)

      self.updateConfigWithFeatures.assertValueCount(1)

      self.vm.inputs.didUpdateConfig()

      self.postNotificationName.assertValues([.ksr_configUpdated])

      self.vm.inputs.setFeatureAtIndexEnabled(index: 1, isEnabled: false)

      self.updateConfigWithFeatures.assertValueCount(2)

      self.vm.inputs.didUpdateConfig()

      self.postNotificationName.assertValues([.ksr_configUpdated, .ksr_configUpdated])
    }
  }
}
