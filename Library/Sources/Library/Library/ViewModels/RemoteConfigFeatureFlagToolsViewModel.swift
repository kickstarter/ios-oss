import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias RemoteConfigFeatures = [(RemoteConfigFeature, Bool)]
public typealias StatsigFeatures = [(StatsigFeature, Bool)]

public protocol RemoteConfigFeatureFlagToolsViewModelOutputs {
  var reloadWithRemoteConfigData: Signal<RemoteConfigFeatures, Never> { get }
  var updateUserDefaultsWithRemoteConfigFeatures: Signal<RemoteConfigFeatures, Never> { get }
  var reloadWithStatsigData: Signal<StatsigFeatures, Never> { get }
  var updateUserDefaultsWithStatsigFeatures: Signal<StatsigFeatures, Never> { get }
}

public protocol RemoteConfigFeatureFlagToolsViewModelInputs {
  func didUpdateUserDefaults()
  func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool)
  func setStatsigFeatureAtIndexEnabled(index: Int, isEnabled: Bool)
  func viewDidLoad()
}

public protocol RemoteConfigFeatureFlagToolsViewModelType {
  var inputs: RemoteConfigFeatureFlagToolsViewModelInputs { get }
  var outputs: RemoteConfigFeatureFlagToolsViewModelOutputs { get }
}

public final class RemoteConfigFeatureFlagToolsViewModel: RemoteConfigFeatureFlagToolsViewModelType,
  RemoteConfigFeatureFlagToolsViewModelInputs,
  RemoteConfigFeatureFlagToolsViewModelOutputs {
  public init() {
    let didUpdateUserDefaultsAndUI = self.didUpdateUserDefaultsProperty.signal
      .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)

    let features = Signal.merge(
      self.viewDidLoadProperty.signal,
      didUpdateUserDefaultsAndUI
    )

    let remoteConfigFeatures = features
      .map { _ in RemoteConfigFeature.allCases }
      .map { features in
        features.map { feature -> (RemoteConfigFeature, Bool) in
          (feature, isFeatureEnabled(feature))
        }
      }

    self.reloadWithRemoteConfigData = remoteConfigFeatures

    self.updateUserDefaultsWithRemoteConfigFeatures = remoteConfigFeatures
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal.skipNil())
      .map(unpack)
      .map { features, index, isEnabled -> RemoteConfigFeatures? in
        let (feature, _) = features[index]
        var mutatedFeatures = features

        setValueInUserDefaults(for: feature, and: isEnabled)

        mutatedFeatures[index] = (feature, isEnabled)
        return mutatedFeatures
      }
      .skipNil()

    // MARK: Statsig

    let statsigFeatures = features
      .map { _ in StatsigFeature.allCases }
      .map { features in
        features.map { feature -> (StatsigFeature, Bool) in
          (feature, isStatsigFeatureEnabled(feature))
        }
      }

    self.reloadWithStatsigData = statsigFeatures

    self.updateUserDefaultsWithStatsigFeatures = statsigFeatures
      .takePairWhen(self.setStatsigFeatureEnabledAtIndexProperty.signal.skipNil())
      .map(unpack)
      .map { features, index, isEnabled -> StatsigFeatures? in
        let (feature, _) = features[index]
        var mutatedFeatures = features

        setStatsigValueInUserDefaults(for: feature, and: isEnabled)

        mutatedFeatures[index] = (feature, isEnabled)
        return mutatedFeatures
      }
      .skipNil()
  }

  // MARK: - Inputs

  private let setFeatureEnabledAtIndexProperty = MutableProperty<(Int, Bool)?>(nil)
  public func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool) {
    self.setFeatureEnabledAtIndexProperty.value = (index, isEnabled)
  }

  private let setStatsigFeatureEnabledAtIndexProperty = MutableProperty<(Int, Bool)?>(nil)
  public func setStatsigFeatureAtIndexEnabled(index: Int, isEnabled: Bool) {
    self.setStatsigFeatureEnabledAtIndexProperty.value = (index, isEnabled)
  }

  private let didUpdateUserDefaultsProperty = MutableProperty(())
  public func didUpdateUserDefaults() {
    self.didUpdateUserDefaultsProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let reloadWithRemoteConfigData: Signal<RemoteConfigFeatures, Never>
  public let updateUserDefaultsWithRemoteConfigFeatures: Signal<RemoteConfigFeatures, Never>
  public let reloadWithStatsigData: Signal<StatsigFeatures, Never>
  public let updateUserDefaultsWithStatsigFeatures: Signal<StatsigFeatures, Never>

  public var inputs: RemoteConfigFeatureFlagToolsViewModelInputs { return self }
  public var outputs: RemoteConfigFeatureFlagToolsViewModelOutputs { return self }
}

// MARK: - Private Helpers (Remote Config)

private func isFeatureEnabled(_ feature: RemoteConfigFeature) -> Bool {
  return featureEnabled(feature: feature)
}

private func setValueInUserDefaults(for feature: RemoteConfigFeature, and value: Bool) {
  AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[feature.rawValue] = value
}

// MARK: - Private Helpers (Statsig)

private func isStatsigFeatureEnabled(_ feature: StatsigFeature) -> Bool {
  if let valueFromDefaults = AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[feature.rawValue] {
    return valueFromDefaults
  }
  return AppEnvironment.current.statsigClient?.checkGate(for: feature) == true
}

private func setStatsigValueInUserDefaults(for feature: StatsigFeature, and value: Bool) {
  AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[feature.rawValue] = value
}
