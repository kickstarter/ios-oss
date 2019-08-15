import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let notifyDelegateLoadPaymentMethodsError = TestObserver<String, Never>()
  private let reloadPaymentMethods = TestObserver<[GraphUserCreditCard.CreditCard], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateLoadPaymentMethodsError
      .observe(self.notifyDelegateLoadPaymentMethodsError.observer)
    self.vm.outputs.reloadPaymentMethods.observe(self.reloadPaymentMethods.observer)
  }

  func testReloadPaymentMethods_LoggedIn() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

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

      self.scheduler.run()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
    }
  }
}
