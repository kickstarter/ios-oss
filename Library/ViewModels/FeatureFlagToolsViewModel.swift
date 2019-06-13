import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol FeatureFlagToolsViewModelOutputs {
  var updateConfigWithFeatures: Signal<Features, Never> { get }
  var reloadWithData: Signal<[(Feature, Bool)], Never> { get }
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

    let features: Signal<[(Feature, Bool)], Never> = Signal.merge(self.viewDidLoadProperty.signal,
                                                                  didUpdateConfigAndUI)
      .map { _ in AppEnvironment.current.config?.features }
      .skipNil()
      .map { configFeatures in
        var features = [(Feature, Bool)]()

        for (key, value) in configFeatures {
          guard let feature = Feature(rawValue: key) else {
            continue
          }

          features.append((feature, value))
        }

        return features
    }

    self.reloadWithData = features

    self.updateConfigWithFeatures = features
      .takePairWhen(self.setFeatureEnabledAtIndexProperty.signal
        .skipNil()
        .skipRepeats({ (prev, curr) -> Bool in
        prev.0 == curr.0 && prev.1 == curr.1
      }))
      .map(unpack)
      .map { features, index, enabled -> Features? in
        let feature = features[index]
        var environmentFeatures = AppEnvironment.current.config?.features
        environmentFeatures?[feature.0.rawValue] = enabled

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

  public let updateConfigWithFeatures: Signal<Features, Never>
  public let reloadWithData: Signal<[(Feature, Bool)], Never>

  public var inputs: FeatureFlagToolsViewModelInputs {
    return self
  }

  public var outputs: FeatureFlagToolsViewModelOutputs {
    return self
  }
}
