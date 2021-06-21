import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias OptimizelyFeatures = [(OptimizelyFeature, Bool)]

public protocol OptimizelyFeatureFlagToolsViewModelOutputs {
  var reloadWithData: Signal<OptimizelyFeatures, Never> { get }
  var updateConfigWithFeatures: Signal<OptimizelyFeatures, Never> { get }
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
          let isEnabledFromServer = AppEnvironment.current.optimizelyClient?
            .isFeatureEnabled(featureKey: feature.rawValue) ?? false

          var isEnabledFromUserDefaults: Bool?

          switch feature {
          case .commentFlaggingEnabled:
            isEnabledFromUserDefaults = AppEnvironment.current.userDefaults.commentFlaggingEnabled
          case .commentThreading:
            isEnabledFromUserDefaults = AppEnvironment.current.userDefaults.commentThreadingEnabled
          case .commentThreadingRepliesEnabled:
            isEnabledFromUserDefaults = AppEnvironment.current.userDefaults.commentThreadingRepliesEnabled
          }

          return (feature, isEnabledFromUserDefaults ?? isEnabledFromServer)
        }
      }

    self.reloadWithData = optimizelyFeatures

    self.updateConfigWithFeatures = optimizelyFeatures
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal.skipNil())
      .map(unpack)
      .map { features, index, isEnabled -> OptimizelyFeatures? in
        let (feature, _) = features[index]
        var mutatedFeatures = features

        switch feature {
        case .commentFlaggingEnabled:
          AppEnvironment.current.userDefaults.commentFlaggingEnabled = isEnabled
        case .commentThreading:
          AppEnvironment.current.userDefaults.commentThreadingEnabled = isEnabled
        case .commentThreadingRepliesEnabled:
          AppEnvironment.current.userDefaults.commentThreadingRepliesEnabled = isEnabled
        }

        mutatedFeatures[index] = (feature, isEnabled)
        return mutatedFeatures
      }
      .skipNil()
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

  public let reloadWithData: Signal<OptimizelyFeatures, Never>
  public let updateConfigWithFeatures: Signal<OptimizelyFeatures, Never>

  public var inputs: OptimizelyFeatureFlagToolsViewModelInputs { return self }
  public var outputs: OptimizelyFeatureFlagToolsViewModelOutputs { return self }
}
