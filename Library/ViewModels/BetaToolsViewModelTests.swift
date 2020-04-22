@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

import Foundation

final class BetaToolsViewModelTests: TestCase {
  let vm: BetaToolsViewModelType = BetaToolsViewModel()

  private let goToBetaFeedback = TestObserver<(), Never>()
  private let goToFeatureFlagTools = TestObserver<(), Never>()
  private let goToPushNotificationTools = TestObserver<(), Never>()
  private let logoutWithParams = TestObserver<DiscoveryParams, Never>()
  private let reloadWithDataCurrentLanguage = TestObserver<String, Never>()
  private let reloadWithDataCurrentEnvironment = TestObserver<String, Never>()
  private let showChangeEnvironmentSheetWithSourceViewIndex = TestObserver<Int, Never>()
  private let showChangeLanguageSheetWithSourceViewIndex = TestObserver<Int, Never>()
  private let showMailDisabledAlert = TestObserver<(), Never>()
  private let updateLanguage = TestObserver<Language, Never>()
  private let updateEnvironment = TestObserver<EnvironmentType, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToBetaFeedback.observe(self.goToBetaFeedback.observer)
    self.vm.outputs.goToFeatureFlagTools.observe(self.goToFeatureFlagTools.observer)
    self.vm.outputs.goToPushNotificationTools.observe(self.goToPushNotificationTools.observer)
    self.vm.outputs.logoutWithParams.observe(self.logoutWithParams.observer)
    self.vm.outputs.reloadWithData.map { $0.0 }.observe(self.reloadWithDataCurrentLanguage.observer)
    self.vm.outputs.reloadWithData.map { $0.1 }.observe(self.reloadWithDataCurrentEnvironment.observer)
    self.vm.outputs.showChangeEnvironmentSheetWithSourceViewIndex
      .observe(self.showChangeEnvironmentSheetWithSourceViewIndex.observer)
    self.vm.outputs.showChangeLanguageSheetWithSourceViewIndex
      .observe(self.showChangeLanguageSheetWithSourceViewIndex.observer)
    self.vm.outputs.showMailDisabledAlert.observe(self.showMailDisabledAlert.observer)
    self.vm.outputs.updateLanguage.observe(self.updateLanguage.observer)
    self.vm.outputs.updateEnvironment.observe(self.updateEnvironment.observer)
  }

  func testBetaTools_LoadWithCorrectValues() {
    withEnvironment(apiService: MockService(serverConfig: ServerConfig.production), language: Language.en) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataCurrentLanguage.assertValues(["English"])
      self.reloadWithDataCurrentEnvironment.assertValues(["Production"])
    }
  }

  func testBetaTools_SwitchesEnvironment() {
    withEnvironment(
      apiService: MockService(serverConfig: ServerConfig.production),
      language: Language.en
    ) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithDataCurrentLanguage.assertValues(["English"])
      self.reloadWithDataCurrentEnvironment.assertValues(["Production"])

      self.vm.inputs.didSelectBetaToolsRow(.changeEnvironment)

      self.showChangeEnvironmentSheetWithSourceViewIndex
        .assertValues([BetaToolsRow.changeEnvironment.rawValue])

      self.vm.inputs.setEnvironment(.production)

      self.updateEnvironment.assertValues([], "Does not emit when the chosen environment is the same.")
      self.vm.inputs.setEnvironment(.staging)

      self.updateEnvironment.assertValues([.staging], "Emits when the chosen environment is different.")

      self.vm.inputs.didUpdateEnvironment()

      self.logoutWithParams.assertValueCount(1)
      self.reloadWithDataCurrentEnvironment
        .assertValues(["Production", "Staging"], "Updates the current environment title")
      self.reloadWithDataCurrentLanguage.assertValues(["English", "English"])
    }
  }

  func testUpdateCurrentLanguage() {
    withEnvironment(
      apiService: MockService(serverConfig: ServerConfig.staging),
      language: Language.en
    ) {
      self.vm.inputs.viewDidLoad()

      self.updateLanguage.assertDidNotEmitValue()

      self.vm.inputs.didSelectBetaToolsRow(.changeLanguage)

      self.showChangeLanguageSheetWithSourceViewIndex
        .assertValues([BetaToolsRow.changeLanguage.rawValue])

      self.vm.inputs.setCurrentLanguage(.en)

      self.updateLanguage.assertDidNotEmitValue(
        "Doesn't update language when the chosen language is the same as the current language."
      )

      self.vm.inputs.setCurrentLanguage(.de)

      self.updateLanguage.assertValues([.de], "Updates the languag.")

      self.reloadWithDataCurrentEnvironment
        .assertValues(["Staging", "Staging"])
      self.reloadWithDataCurrentLanguage
        .assertValues(["English", "German"], "Updates the current language title.")
    }
  }

  func testSendBetaFeedbackButton_canSendMail() {
    withEnvironment(language: Language.en) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.betaFeedbackButtonTapped(canSendMail: true)

      self.goToBetaFeedback.assertDidEmitValue()
    }
  }

  func testSendBetaFeedbackButton_cannotSendMail() {
    withEnvironment(language: Language.en) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.betaFeedbackButtonTapped(canSendMail: false)

      self.showMailDisabledAlert.assertDidEmitValue()
      self.goToBetaFeedback.assertDidNotEmitValue()
    }
  }

  func testGoToDebugPushNotifications() {
    self.vm.inputs.viewDidLoad()

    self.goToBetaFeedback.assertDidNotEmitValue()

    self.vm.inputs.didSelectBetaToolsRow(.debugPushNotifications)

    self.goToPushNotificationTools.assertValueCount(1)
  }

  func testGoToFeatureFlags() {
    self.vm.inputs.viewDidLoad()

    self.goToFeatureFlagTools.assertDidNotEmitValue()

    self.vm.inputs.didSelectBetaToolsRow(.debugFeatureFlags)

    self.goToFeatureFlagTools.assertValueCount(1)
  }
}
