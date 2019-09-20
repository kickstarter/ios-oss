import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let applePayButtonHidden = TestObserver<Bool, Never>()
  private let newCardAdded = TestObserver<GraphUserCreditCard.CreditCard, Never>()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateLoadPaymentMethodsError = TestObserver<String, Never>()
  private let reloadPaymentMethods = TestObserver<[GraphUserCreditCard.CreditCard], Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.applePayButtonHidden.observe(self.applePayButtonHidden.observer)
    self.vm.outputs.newCardAdded.observe(self.newCardAdded.observer)
    self.vm.outputs.notifyDelegateApplePayButtonTapped
     .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateLoadPaymentMethodsError
      .observe(self.notifyDelegateLoadPaymentMethodsError.observer)
    self.vm.outputs.reloadPaymentMethods.observe(self.reloadPaymentMethods.observer)
  }

  func testNewCardAdded() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.amex

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.newCardAdded.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
      self.vm.inputs.successfullyAddedCard(newCard: userCreditCard)

      self.newCardAdded.assertValue(userCreditCard)
    }
  }

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isFalse() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
    }
  }

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isTrue() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isFalse() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isTrue() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_LoggedOut() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: nil) {
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertDidNotEmitValue()
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
    }
  }

  func testApplePayButtonTapped() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith((user: .template, project: .template, true))
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
    }
  }

  func testApplePayButton_isHidden_applePayCapable_unsupportedProjectCountry() {
    let mockConfig = Config.template
      |> \.applePayCountries .~ [Project.Country.us.countryCode]
    let project = Project.template
      |> \.country .~ .gb

    withEnvironment(config: mockConfig) {
      self.vm.inputs.configureWith((User.template, project, true))
      self.vm.inputs.viewDidLoad()

      self.applePayButtonHidden.assertValues([true])
    }
  }

  func testApplePayButton_isNotHidden_applePayCapable_supportedProjectCountry() {
    let mockConfig = Config.template
      |> \.applePayCountries .~ [
        Project.Country.us.countryCode,
        Project.Country.gb.countryCode
      ]
    let project = Project.template
      |> \.country .~ .gb

    withEnvironment(config: mockConfig) {
      self.vm.inputs.configureWith((User.template, project, true))
      self.vm.inputs.viewDidLoad()

      self.applePayButtonHidden.assertValues([false])
    }
  }
}
