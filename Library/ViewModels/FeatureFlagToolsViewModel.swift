import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias FeatureEnabled = (feature: Feature, isEnabled: Bool)

public protocol FeatureFlagToolsViewModelOutputs {
  var reloadWithData: Signal<[FeatureEnabled], Never> { get }
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

    let features: Signal<[FeatureEnabled], Never> = Signal.merge(
      self.viewDidLoadProperty.signal,
      didUpdateConfigAndUI
    )
    .map { _ in AppEnvironment.current.config?.features }
    .skipNil()
    .map { configFeatures in
      var features = [FeatureEnabled]()

      for (key, value) in configFeatures {
        guard let feature = Feature(rawValue: key) else {
          continue
        }

        features.append((feature: feature, isEnabled: value))
      }

      return features
    }

    self.reloadWithData = features

    self.updateConfigWithFeatures = features
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal
        .skipNil())
      .map(unpack)
      .map { features, index, enabled -> Features? in
        let featureEnabledPair = features[index]

        guard featureEnabledPair.isEnabled != enabled else {
          return nil
        }

        var environmentFeatures = AppEnvironment.current.config?.features
        environmentFeatures?[featureEnabledPair.feature.rawValue] = enabled

        return environmentFeatures
      }.skipNil()
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

  public let reloadWithData: Signal<[FeatureEnabled], Never>
  public let updateConfigWithFeatures: Signal<Features, Never>

  public var inputs: FeatureFlagToolsViewModelInputs {
    return self
  }

  public var outputs: FeatureFlagToolsViewModelOutputs {
    return self
  }
}
