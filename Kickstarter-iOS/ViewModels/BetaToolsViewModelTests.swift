import XCTest
import ReactiveSwift
import Result
@testable import KsApi
@testable import Library
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers

import Foundation

final class BetaToolsViewModelTests: TestCase {
  let vm: BetaToolsViewModelType = BetaToolsViewModel()

  let currentLanguage = TestObserver<Language, NoError>()
  let environmentSwitcherButtonTitle = TestObserver<String, NoError>()
  let goToBetaFeedback = TestObserver<(), NoError>()
  let betaFeedbackMailDisabled = TestObserver<(), NoError>()
  let logoutWithParams = TestObserver<DiscoveryParams, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.currentLanguage.observe(self.currentLanguage.observer)
    self.vm.outputs.environmentSwitcherButtonTitle.observe(self.environmentSwitcherButtonTitle.observer)
    self.vm.outputs.goToBetaFeedback.observe(self.goToBetaFeedback.observer)
    self.vm.outputs.logoutWithParams.observe(self.logoutWithParams.observer)
    self.vm.outputs.betaFeedbackMailDisabled.observe(self.betaFeedbackMailDisabled.observer)
  }

  func testEnvironmentButton_SwitchesEnvironment() {

    withEnvironment(apiService: MockService(serverConfig: ServerConfig.production)) {

      self.vm.inputs.environmentSwitcherButtonTapped(environment: EnvironmentType.staging)

      XCTAssertEqual(AppEnvironment.current.apiService.serverConfig.environment.rawValue, "Staging")

      self.vm.inputs.environmentSwitcherButtonTapped(environment: EnvironmentType.local)

      XCTAssertEqual(AppEnvironment.current.apiService.serverConfig.environment.rawValue, "Local")
    }
  }

  func testLogoutWithParamsEmits_WhenEnvironmentChanges() {

    withEnvironment(apiService: MockService(serverConfig: ServerConfig.production)) {

      self.vm.inputs.environmentSwitcherButtonTapped(environment: EnvironmentType.staging)
      self.logoutWithParams.assertDidEmitValue()
    }
  }
  
  func testLogoutWithParamsDoesNotEmit_WhenEnvironmentChangesToCurrentEnvironment() {
    withEnvironment(apiService: MockService(serverConfig: ServerConfig.production)) {
      self.vm.inputs.environmentSwitcherButtonTapped(environment: EnvironmentType.production)
      
      self.logoutWithParams.assertDidNotEmitValue()
    }
  }

  func testEnvironmentButtonTitle_showsEnvironment_WhenEnvironmentChanges() {

    self.vm.inputs.viewDidLoad()

    self.environmentSwitcherButtonTitle.assertValue("Production")

    self.vm.inputs.environmentSwitcherButtonTapped(environment: EnvironmentType.staging)
    self.environmentSwitcherButtonTitle.assertValues(["Production", "Staging"])

    self.vm.inputs.environmentSwitcherButtonTapped(environment: EnvironmentType.local)
    self.environmentSwitcherButtonTitle.assertValues(["Production", "Staging", "Local"])
  }

  func testSetCurrentLanguage() {
    withEnvironment(language: Language.en) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.setCurrentLanguage(.de)

      self.currentLanguage.assertValue(.de)
    }
  }

  func testSetCurrentLanguage_filtersWhenCurrentEnvLanguageIsTheSame() {
    withEnvironment(language: Language.en) {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.setCurrentLanguage(.en)

      self.currentLanguage.assertValueCount(0)
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

      self.betaFeedbackMailDisabled.assertDidEmitValue()
    }
  }
}
