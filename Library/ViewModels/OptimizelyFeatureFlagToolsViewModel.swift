import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias OptimizelyFeatures = [(OptimizelyFeature, Bool)]

public protocol OptimizelyFeatureFlagToolsViewModelOutputs {
  var reloadWithData: Signal<OptimizelyFeatures, Never> { get }
  var updateUserDefaultsWithFeatures: Signal<OptimizelyFeatures, Never> { get }
}

public protocol OptimizelyFeatureFlagToolsViewModelInputs {
  func didUpdateUserDefaults()
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
    let didUpdateUserDefaultsAndUI = self.didUpdateUserDefaultsProperty.signal
      .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)

    let features = Signal.merge(
      self.viewDidLoadProperty.signal,
      didUpdateUserDefaultsAndUI
    )
    .map { _ in AppEnvironment.current.optimizelyClient?.allFeatures() }
    .skipNil()

    let optimizelyFeatures = features
      .map { features in
        features.map { feature -> (OptimizelyFeature, Bool) in
          let isEnabledFromServer = AppEnvironment.current.optimizelyClient?
            .isFeatureEnabled(featureKey: feature.rawValue) ?? false

          let isEnabledFromUserDefaults = getValueFromUserDefaults(for: feature)

          return (feature, isEnabledFromUserDefaults ?? isEnabledFromServer)
        }
      }

    self.reloadWithData = optimizelyFeatures

    self.updateUserDefaultsWithFeatures = optimizelyFeatures
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal.skipNil())
      .map(unpack)
      .map { features, index, isEnabled -> OptimizelyFeatures? in
        let (feature, _) = features[index]
        var mutatedFeatures = features

        setValueInUserDefaults(for: feature, and: isEnabled)

        mutatedFeatures[index] = (feature, isEnabled)
        return mutatedFeatures
      }
      .skipNil()
  }

  private let setFeatureEnabledAtIndexProperty = MutableProperty<(Int, Bool)?>(nil)
  public func setFeatureAtIndexEnabled(index: Int, isEnabled: Bool) {
    self.setFeatureEnabledAtIndexProperty.value = (index, isEnabled)
  }

  private let didUpdateUserDefaultsProperty = MutableProperty(())
  public func didUpdateUserDefaults() {
    self.didUpdateUserDefaultsProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadWithData: Signal<OptimizelyFeatures, Never>
  public let updateUserDefaultsWithFeatures: Signal<OptimizelyFeatures, Never>

  public var inputs: OptimizelyFeatureFlagToolsViewModelInputs { return self }
  public var outputs: OptimizelyFeatureFlagToolsViewModelOutputs { return self }
}

// MARK: - Private Helpers

/** Returns the value of the User Defaults key in the AppEnvironment.
 */
private func getValueFromUserDefaults(for feature: OptimizelyFeature) -> Bool? {
  switch feature {
  case .commentFlaggingEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.commentFlaggingEnabled.rawValue]
  case .projectPageStoryTabEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.projectPageStoryTabEnabled.rawValue]
  case .rewardLocalPickupEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.rewardLocalPickupEnabled.rawValue]
  case .paymentSheetEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.paymentSheetEnabled.rawValue]
  case .settingsPaymentSheetEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.settingsPaymentSheetEnabled.rawValue]
  case .facebookLoginDeprecationEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue]
  }
}

/** Sets the value for the UserDefaults key in the AppEnvironment.
 */
private func setValueInUserDefaults(for feature: OptimizelyFeature, and value: Bool) {
  switch feature {
  case .commentFlaggingEnabled:
    AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.commentFlaggingEnabled.rawValue] = value
  case .projectPageStoryTabEnabled:
    AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.projectPageStoryTabEnabled.rawValue] = value
  case .rewardLocalPickupEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.rewardLocalPickupEnabled.rawValue] = value
  case .paymentSheetEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.paymentSheetEnabled.rawValue] = value
  case .settingsPaymentSheetEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.settingsPaymentSheetEnabled.rawValue] = value
  case .facebookLoginDeprecationEnabled:
    return AppEnvironment.current.userDefaults
      .optimizelyFeatureFlags[OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue] = value
  }
}
