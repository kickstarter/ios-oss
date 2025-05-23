import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public enum BetaToolsRow: Int, CaseIterable {
  case debugConfigFeatureFlags
  case debugRemoteConfigFeatureFlags
  case debugPushNotifications
  case designSystem
  case colors
  case paginatedScrollView
  case changeEnvironment
  case changeLanguage

  public var cellStyle: UITableViewCell.CellStyle {
    switch self {
    case .debugConfigFeatureFlags, .debugRemoteConfigFeatureFlags, .debugPushNotifications: return .default
    default: return .value1
    }
  }

  public var selectionStyle: UITableViewCell.SelectionStyle {
    switch self {
    case .changeEnvironment, .changeLanguage: return .none
    default: return .default
    }
  }

  public var titleText: String {
    switch self {
    case .debugConfigFeatureFlags: return "Config Feature Flags"
    case .debugRemoteConfigFeatureFlags: return "Remote Config Feature Flags"
    case .debugPushNotifications: return "Debug Push Notifications"
    case .designSystem: return "Design System"
    case .colors: return "Semantic Colors"
    case .paginatedScrollView: return "Paginated Scroll View"
    case .changeEnvironment: return "Change Environment"
    case .changeLanguage: return "Change Language"
    }
  }

  public var rightIconImageName: String? {
    switch self {
    case .debugConfigFeatureFlags, .debugRemoteConfigFeatureFlags,
         .debugPushNotifications, .paginatedScrollView, .designSystem, .colors: return "chevron-right"
    default: return nil
    }
  }

  public func detailText(from data: BetaToolsData) -> String? {
    switch self {
    case .changeEnvironment: return data.currentEnvironment
    case .changeLanguage: return data.currentLanguage
    default: return nil
    }
  }
}

public protocol BetaToolsViewModelInputs {
  func betaFeedbackButtonTapped(canSendMail: Bool)
  func didSelectBetaToolsRow(_ row: BetaToolsRow)
  func didUpdateEnvironment()
  func setEnvironment(_ environment: EnvironmentType)
  func setCurrentLanguage(_ language: Language)
  func viewDidLoad()
}

public typealias BetaToolsData = (currentLanguage: String, currentEnvironment: String)

public protocol BetaToolsViewModelOutputs {
  var goToBetaFeedback: Signal<(), Never> { get }
  var goToConfigFeatureFlagTools: Signal<(), Never> { get }
  var goToRemoteConfigFeatureFlagTools: Signal<(), Never> { get }
  var goToPushNotificationTools: Signal<(), Never> { get }
  var goToPaginatedScrollView: Signal<(), Never> { get }
  var goToDesignSystem: Signal<(), Never> { get }
  var goToColors: Signal<(), Never> { get }
  var logoutWithParams: Signal<DiscoveryParams, Never> { get }
  var reloadWithData: Signal<BetaToolsData, Never> { get }
  var showChangeEnvironmentSheetWithSourceViewIndex: Signal<Int, Never> { get }
  var showChangeLanguageSheetWithSourceViewIndex: Signal<Int, Never> { get }
  var showMailDisabledAlert: Signal<(), Never> { get }
  var updateLanguage: Signal<Language, Never> { get }
  var updateEnvironment: Signal<EnvironmentType, Never> { get }
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
    let languageFromAppEnvironment = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.language }
    let serverConfigEnvironmentFromAppEnvironment = self.viewDidLoadProperty.signal
      .map { _ in AppEnvironment.current.apiService.serverConfig.environment }

    self.updateLanguage = languageFromAppEnvironment
      .takePairWhen(self.currentLanguageProperty.signal.skipRepeats())
      .filter(!=)
      .map(second)

    let currentLanguageString = Signal.merge(languageFromAppEnvironment, self.updateLanguage)
      .map { $0.displayString }

    self.updateEnvironment = serverConfigEnvironmentFromAppEnvironment
      .takePairWhen(self.environmentProperty.signal.skipRepeats())
      .filter(!=)
      .map(second)
      .skipNil()

    let currentEnvironmentString = Signal.merge(
      serverConfigEnvironmentFromAppEnvironment,
      self.updateEnvironment
    )
    .map { $0.description }

    self.reloadWithData = Signal.combineLatest(
      currentLanguageString,
      currentEnvironmentString
    )
    .map { BetaToolsData(
      currentLanguage: $0.0,
      currentEnvironment: $0.1
    ) }

    self.goToBetaFeedback = self.canSendMailProperty.signal.filter(isTrue).ignoreValues()

    let betaFeedbackMailDisabled = self.canSendMailProperty.signal.filter(isFalse)

    self.showMailDisabledAlert = betaFeedbackMailDisabled.ignoreValues()

    self.goToPushNotificationTools = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.debugPushNotifications }
      .ignoreValues()

    self.goToConfigFeatureFlagTools = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.debugConfigFeatureFlags }
      .ignoreValues()

    self.goToRemoteConfigFeatureFlagTools = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.debugRemoteConfigFeatureFlags }
      .ignoreValues()

    self.goToPaginatedScrollView = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.paginatedScrollView }
      .ignoreValues()

    self.goToDesignSystem = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.designSystem }
      .ignoreValues()

    self.showChangeEnvironmentSheetWithSourceViewIndex = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.changeEnvironment }
      .map { $0.rawValue }

    self.showChangeLanguageSheetWithSourceViewIndex = self.didSelectBetaToolsRowProperty.signal
      .skipNil()
      .filter { $0 == BetaToolsRow.changeLanguage }
      .map { $0.rawValue }

    self.goToColors =
      self.didSelectBetaToolsRowProperty.signal
        .skipNil()
        .filter { $0 == BetaToolsRow.colors }
        .ignoreValues()

    self.logoutWithParams = self.didUpdateEnvironmentProperty.signal
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

  private let didSelectBetaToolsRowProperty = MutableProperty<BetaToolsRow?>(nil)
  public func didSelectBetaToolsRow(_ row: BetaToolsRow) {
    self.didSelectBetaToolsRowProperty.value = row
  }

  private let didUpdateEnvironmentProperty = MutableProperty(())
  public func didUpdateEnvironment() {
    self.didUpdateEnvironmentProperty.value = ()
  }

  private let environmentProperty = MutableProperty<EnvironmentType?>(nil)
  public func setEnvironment(_ environment: EnvironmentType) {
    self.environmentProperty.value = environment
  }

  private let currentLanguageProperty = MutableProperty(AppEnvironment.current.language)
  public func setCurrentLanguage(_ language: Language) {
    self.currentLanguageProperty.value = language
  }

  public let goToBetaFeedback: Signal<(), Never>
  public let goToConfigFeatureFlagTools: Signal<(), Never>
  public let goToRemoteConfigFeatureFlagTools: Signal<(), Never>
  public let goToPushNotificationTools: Signal<(), Never>
  public let goToPaginatedScrollView: Signal<(), Never>
  public let goToDesignSystem: Signal<(), Never>
  public let goToColors: Signal<(), Never>
  public let updateLanguage: Signal<Language, Never>
  public let updateEnvironment: Signal<EnvironmentType, Never>
  public let logoutWithParams: Signal<DiscoveryParams, Never>
  public let reloadWithData: Signal<BetaToolsData, Never>
  public let showMailDisabledAlert: Signal<(), Never>
  public let showChangeEnvironmentSheetWithSourceViewIndex: Signal<Int, Never>
  public let showChangeLanguageSheetWithSourceViewIndex: Signal<Int, Never>
}
