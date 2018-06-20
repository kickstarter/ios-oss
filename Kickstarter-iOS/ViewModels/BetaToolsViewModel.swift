import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol BetaToolsViewModelInputs {
  func betaFeedbackButtonTapped(canSendMail: Bool)
  func environmentSwitcherButtonTapped(environment: EnvironmentType)
  func setCurrentLanguage(_ language: Language)
  func viewDidLoad()
}

public protocol BetaToolsViewModelOutputs {
  var currentLanguage: Signal<Language, NoError> { get }
  var environmentSwitcherButtonTitle: Signal<String, NoError> { get }
  var goToBetaFeedback: Signal<(), NoError> { get }
  var betaFeedbackMailDisabled: Signal<(), NoError> { get }
  var logoutWithParams: Signal<DiscoveryParams, NoError> { get }
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
    self.goToBetaFeedback = self.canSendMailProperty.signal.filter({ canSendMail -> Bool in
      return canSendMail == true
    }).ignoreValues()

    self.betaFeedbackMailDisabled = self.canSendMailProperty.signal.filter({ (canSendMail) -> Bool in
      return canSendMail == false
    }).ignoreValues()

    self.currentLanguage = self.currentLanguageProperty.signal
      .skipRepeats()
      .filter { AppEnvironment.current.language != $0 }

    let updateEnvironment = self.environmentSwitcherButtonTappedProperty.signal.skipNil()
      .filter { AppEnvironment.current.apiService.serverConfig.environment != $0 }

    _ = updateEnvironment
      .map(ServerConfig.config(for:))
      .observeValues { config in
        AppEnvironment.updateServerConfig(config)
    }

    self.environmentSwitcherButtonTitle = Signal.merge(
      updateEnvironment.ignoreValues(),
      viewDidLoadProperty.signal.ignoreValues()
      ).map { _ in
        return AppEnvironment.current.apiService.serverConfig.environment.rawValue
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

  public let goToBetaFeedback: Signal<(), NoError>
  public let betaFeedbackMailDisabled: Signal<(), NoError>
  public let currentLanguage: Signal<Language, NoError>
  public let environmentSwitcherButtonTitle: Signal<String, NoError>
  public let logoutWithParams: Signal<DiscoveryParams, NoError>
}
