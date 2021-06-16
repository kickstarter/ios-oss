import Foundation
import KsApi
import Prelude
import ReactiveSwift

// public typealias FeatureEnabled = (feature: Feature, isEnabled: Bool)
public typealias OptimizelyFeatures = [(OptimizelyFeature, Bool)]

public protocol OptimizelyFeatureFlagToolsViewModelOutputs {
//  var postNotification: Signal<Notification, Never> { get }
  var reloadWithData: Signal<OptimizelyFeatures, Never> { get }
//  var updateConfigWithFeatures: Signal<OptimizelyFeatures, Never> { get }
}

public protocol OptimizelyFeatureFlagToolsViewModelInputs {
  func didUpdateConfig()
  func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool)
  func viewDidLoad()
}

public protocol OptimizelyFeatureFlagToolsViewModelType {
  var inputs: OptimizelyFeatureFlagToolsViewModelInputs { get }
  var outputs: OptimizelyFeatureFlagToolsViewModelOutputs { get }
}

public final class OptimizelyFeatureFlagToolsViewModel: OptimizelyFeatureFlagToolsViewModelType,
  OptimizelyFeatureFlagToolsViewModelInputs,
  OptimizelyFeatureFlagToolsViewModelOutputs {
  public init() {
    let didUpdateConfigAndUI = self.didUpdateConfigProperty.signal
      .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)

    let features = Signal.merge(
      self.viewDidLoadProperty.signal,
      didUpdateConfigAndUI
    )
    .map { _ in AppEnvironment.current.optimizelyClient?.allFeatures() }
    .skipNil()

    let optimizelyFeatures = features
      .map { features in
        features.map { feature -> (OptimizelyFeature, Bool) in
          let isEnabled = AppEnvironment.current.optimizelyClient?
            .isFeatureEnabled(featureKey: feature.rawValue) ?? false

          return (feature, isEnabled)
        }
      }

    self.reloadWithData = optimizelyFeatures

//    self.updateConfigWithFeatures = sortedFeatures
//      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal.skipNil())
//      .map(unpack)
//      .map { features, index, enabled -> Features? in
//        guard features.count > index else {
//          return nil
//        }
//        let featureEnabledPair = features[index]
//
//        guard featureEnabledPair.value != enabled else {
//          return nil
//        }
//
//        var environmentFeatures = AppEnvironment.current.config?.features
//        environmentFeatures?[featureEnabledPair.key] = enabled
//
//        return environmentFeatures
//      }
//      .skipNil()
//
//    self.postNotification = self.didUpdateConfigProperty.signal
//      .mapConst(Notification(name: .ksr_configUpdated, object: nil))
  }

  private let setFeatureEnabledAtIndexProperty = MutableProperty<(Int, Bool)?>(nil)
  public func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool) {
    self.setFeatureEnabledAtIndexProperty.value = (index, isEnabled)
  }

  private let didUpdateConfigProperty = MutableProperty(())
  public func didUpdateConfig() {
    self.didUpdateConfigProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

//  public let postNotification: Signal<Notification, Never>
  public let reloadWithData: Signal<OptimizelyFeatures, Never>
//  public let updateConfigWithFeatures: Signal<Features, Never>

  public var inputs: OptimizelyFeatureFlagToolsViewModelInputs { return self }
  public var outputs: OptimizelyFeatureFlagToolsViewModelOutputs { return self }
}

// public func featureEnabledFromDictionaries(_ dictionaryArray: [Features]) -> [FeatureEnabled] {
//  return dictionaryArray.compactMap { dictionary -> (Feature, Bool)? in
//    dictionary.compactMap { key, value in
//      guard let feature = Feature(rawValue: key) else { return nil }
//      return (feature, value)
//    }
//    .first
//  }
// }
