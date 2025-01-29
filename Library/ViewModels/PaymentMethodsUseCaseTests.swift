import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PaymentMethodsUseCaseTests: TestCase {
  private var useCase: PaymentMethodsUseCase!

  private var paymentMethodsViewHidden = TestObserver<Bool, Never>()
  private var configureWithValue = TestObserver<PledgePaymentMethodsValue, Never>()
  private var selectedPaymentSource = TestObserver<PaymentSourceSelected?, Never>()

  private let (initialDataSignal, initialDataObserver) = Signal<PledgeViewData, Never>
    .pipe()
  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>
    .pipe()

  override func setUp() {
    super.setUp()

    self.useCase = PaymentMethodsUseCase(
      initialData: self.initialDataSignal,
      userSessionStarted: self.userSessionStartedSignal
    )

    self.useCase.uiOutputs.paymentMethodsViewHidden.observe(self.paymentMethodsViewHidden.observer)
    self.useCase.uiOutputs.configurePaymentMethodsViewControllerWithValue
      .observe(self.configureWithValue.observer)
    self.useCase.dataOutputs.selectedPaymentSource.observe(self.selectedPaymentSource.observer)
  }

  func test_LoggedInUser_SendsConfigValue_AndShowsPaymentMethods() {
    let project = Project.template
    let reward = Reward.template

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 10.0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    self.configureWithValue.assertDidNotEmitValue()
    self.paymentMethodsViewHidden.assertDidNotEmitValue()

    self.initialDataObserver.send(value: data)

    self.configureWithValue.assertDidNotEmitValue("Nobody is logged in, so no event should have been sent.")
    self.paymentMethodsViewHidden.assertLastValue(
      true,
      "Nobody is logged in, so payment methods should be hidden."
    )

    withEnvironment(currentUser: User.template) {
      self.initialDataObserver.send(value: data)

      self.configureWithValue
        .assertDidEmitValue("A user is logged in, so a configuration event should be sent.")
      self.paymentMethodsViewHidden.assertLastValue(
        false,
        "A user is logged in, so payment methods should be shown."
      )
    }
  }

  func test_UpdatingRewardContext_DoesntSendConfigValue_AndHidesPaymentMethods() {
    let project = Project.template
    let reward = Reward.template

    let updateData = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 10.0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .updateReward
    )

    withEnvironment(currentUser: User.template) {
      self.initialDataObserver.send(value: updateData)

      self.configureWithValue
        .assertDidNotEmitValue(
          "You can't change your payment method when updating a reward, so a configuration event shouldn't be sent."
        )
      self.paymentMethodsViewHidden.assertValue(
        true,
        "You can't change your payment method when updating a reward, so payment methods should be hidden."
      )
    }
  }

  func test_SelectedPaymentSource_ChangesWhenCardIsSelected() {
    let project = Project.template
    let reward = Reward.template

    let updateData = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 10.0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .pledge
    )

    withEnvironment(currentUser: User.template) {
      self.selectedPaymentSource.assertDidNotEmitValue()

      self.initialDataObserver.send(value: updateData)
      self.selectedPaymentSource.assertLastValue(nil, "Default selected payment source should be nil.")

      let card = PaymentSourceSelected.savedCreditCard("123", "pm_fake")

      self.useCase.uiInputs.creditCardSelected(with: card)
      self.selectedPaymentSource.assertDidEmitValue()
      XCTAssertEqual(self.selectedPaymentSource.lastValue!, card)
    }
  }
}
