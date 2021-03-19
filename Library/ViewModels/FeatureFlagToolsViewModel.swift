import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias FeatureEnabled = (feature: Feature, isEnabled: Bool)

public protocol FeatureFlagToolsViewModelOutputs {
  var postNotification: Signal<Notification, Never> { get }
  var reloadWithData: Signal<[Features], Never> { get }
  var updateConfigWithFeatures: Signal<Features, Never> { get }
}

public protocol FeatureFlagToolsViewModelInputs {
  func didUpdateConfig()
  func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool)
  func viewDidLoad()
}

public protocol FeatureFlagToolsViewModelType {
  var inputs: FeatureFlagToolsViewModelInputs { get }
  var outputs: FeatureFlagToolsViewModelOutputs { get }
}

public final class FeatureFlagToolsViewModel: FeatureFlagToolsViewModelType, FeatureFlagToolsViewModelInputs,
  FeatureFlagToolsViewModelOutputs {
  public init() {
    let didUpdateConfigAndUI = self.didUpdateConfigProperty.signal
      .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)

    let features = Signal.merge(
      self.viewDidLoadProperty.signal,
      didUpdateConfigAndUI
    )
    .map { _ in AppEnvironment.current.config?.features }
    .skipNil()

    let sortedFeatures = features
      .map { features in Array(features)
        .filter { Feature(rawValue: $0.0) != nil }
        .sorted(by: { $0.0 < $1.0 })
      }

    self.reloadWithData = sortedFeatures.map { featureTuples in
      featureTuples.map { key, value in [key: value] }
    }

    self.updateConfigWithFeatures = sortedFeatures
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal.skipNil())
      .map(unpack)
      .map { features, index, enabled -> Features? in
        guard features.count > index else {
          return nil
        }
        let featureEnabledPair = features[index]

        guard featureEnabledPair.value != enabled else {
          return nil
        }

        var environmentFeatures = AppEnvironment.current.config?.features
        environmentFeatures?[featureEnabledPair.key] = enabled

        return environmentFeatures
      }
      .skipNil()

    self.postNotification = self.didUpdateConfigProperty.signal
      .mapConst(Notification(name: .ksr_configUpdated, object: nil))
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

  public let postNotification: Signal<Notification, Never>
  public let reloadWithData: Signal<[Features], Never>
  public let updateConfigWithFeatures: Signal<Features, Never>

  public var inputs: FeatureFlagToolsViewModelInputs { return self }
  public var outputs: FeatureFlagToolsViewModelOutputs { return self }
}

public func featureEnabledFromDictionaries(_ dictionaryArray: [Features]) -> [FeatureEnabled] {
  return dictionaryArray.compactMap { dictionary -> (Feature, Bool)? in
    dictionary.compactMap { key, value in
      guard let feature = Feature(rawValue: key) else { return nil }
      return (feature, value)
    }
    .first
  }
}
