import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol BetaToolsViewModelInputs {
  func betaFeedbackButtonTapped(canSendMail: Bool)
  func environmentSwitcherButtonTapped(environment: EnvironmentType)
  func setCurrentLanguage(_ language: Language)
  func viewDidLoad()
}

public protocol BetaToolsViewModelOutputs {
  var currentLanguage: Signal<Language, Never> { get }
  var environmentSwitcherButtonTitle: Signal<String, Never> { get }
  var goToBetaFeedback: Signal<(), Never> { get }
  var betaFeedbackMailDisabled: Signal<(), Never> { get }
  var logoutWithParams: Signal<DiscoveryParams, Never> { get }
}

public protocol BetaToolsViewModelType {
  var inputs: BetaToolsViewModelInputs { get }
  var outputs: BetaToolsViewModelOutputs { get }
}

public final class BetaToolsViewModel: BetaToolsViewModelType,
  BetaToolsViewModelInputs, BetaToolsViewModelOutputs {
  public var inputs: BetaToolsViewModelInputs {
    return self
  }

  public var outputs: BetaToolsViewModelOutputs {
    return self
  }

  public init() {
    self.goToBetaFeedback = self.canSendMailProperty.signal.filter(isTrue).ignoreValues()
    self.betaFeedbackMailDisabled = self.canSendMailProperty.signal.filter(isFalse).ignoreValues()

    self.currentLanguage = self.currentLanguageProperty.signal
      .skipRepeats()
      .filter { AppEnvironment.current.language != $0 }

    let updateEnvironment = self.environmentSwitcherButtonTappedProperty.signal.skipNil()
      .filter { AppEnvironment.current.apiService.serverConfig.environment != $0 }
      .map(ServerConfig.config(for:))
      .on(value: AppEnvironment.updateServerConfig)

    self.environmentSwitcherButtonTitle = Signal.merge(
      updateEnvironment.ignoreValues(),
      self.viewDidLoadProperty.signal.ignoreValues()
    ).map { _ in
      AppEnvironment.current.apiService.serverConfig.environment.rawValue
    }.skipRepeats()

    self.logoutWithParams = updateEnvironment.ignoreValues()
      .map {
        .defaults
          |> DiscoveryParams.lens.includePOTD .~ true
          |> DiscoveryParams.lens.sort .~ .magic
      }
  }

  fileprivate let canSendMailProperty = MutableProperty(true)
  public func betaFeedbackButtonTapped(canSendMail: Bool) {
    self.canSendMailProperty.value = canSendMail
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let environmentSwitcherButtonTappedProperty = MutableProperty<EnvironmentType?>(nil)
  public func environmentSwitcherButtonTapped(environment: EnvironmentType) {
    self.environmentSwitcherButtonTappedProperty.value = environment
  }

  fileprivate let currentLanguageProperty = MutableProperty(AppEnvironment.current.language)
  public func setCurrentLanguage(_ language: Language) {
    self.currentLanguageProperty.value = language
  }

  public let goToBetaFeedback: Signal<(), Never>
  public let betaFeedbackMailDisabled: Signal<(), Never>
  public let currentLanguage: Signal<Language, Never>
  public let environmentSwitcherButtonTitle: Signal<String, Never>
  public let logoutWithParams: Signal<DiscoveryParams, Never>
}
