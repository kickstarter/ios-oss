import Foundation
import KsApi
import ReactiveSwift

public protocol PledgeRedemptionViewModelInputs {
  func addPaymentMethodButtonTapped()
  func pledgeButtonTapped(paymentMethodId: String)
  func confirmPaymentSuccessful(clientSecret: String)
  func viewDidLoad()
}

public protocol PledgeRedemptionViewModelOutputs {
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var completeOrder: Signal<(clientSecret: String, status: String)?, Never> { get }
  var showErrorBanner: Signal<ErrorEnvelope, Never> { get }
}

public protocol PledgeRedemptionViewModelType {
  var inputs: PledgeRedemptionViewModelInputs { get }
  var outputs: PledgeRedemptionViewModelOutputs { get }
}

public class PledgeRedemptionViewModel: PledgeRedemptionViewModelType, PledgeRedemptionViewModelInputs,
  PledgeRedemptionViewModelOutputs {
  public init() {
    self.configureStripeIntegration = self.viewDidLoadProperty.signal
      .map { _ in
        (
          Secrets.ApplePay.merchantIdentifier,
          AppEnvironment.current.environmentType.stripePublishableKey
        )
      }

    let completeOrderResult = self.pledgeButtonTappedProperty.signal
      .switchMap { paymentMethodId in
        AppEnvironment.current.apiService
          .completeOrder(
            input: CompleteOrderInput(
              projectId: "UHJvamVjdC01NzYyNDQ0OTk=",
              stripePaymentMethodId: paymentMethodId
            )
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.completeOrder = completeOrderResult.values()
      .map { ($0.clientSecret, $0.status) }

    self.showErrorBanner = completeOrderResult.errors()
      .map { err in
        err
      }
  }

  // MARK: - Inputs

  private let confirmPaymentSuccessfulProperty = MutableProperty<String?>(nil)
  public func confirmPaymentSuccessful(clientSecret: String) {
    self.confirmPaymentSuccessfulProperty.value = clientSecret
  }

  private let addPaymentMethodButtonTappedProperty = MutableProperty(())
  public func addPaymentMethodButtonTapped() {
    self.addPaymentMethodButtonTappedProperty.value = ()
  }

  private let pledgeButtonTappedProperty = MutableProperty<String?>(nil)
  public func pledgeButtonTapped(paymentMethodId: String) {
    self.pledgeButtonTappedProperty.value = paymentMethodId
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let completeOrder: Signal<(clientSecret: String, status: String)?, Never>
  public let configureStripeIntegration: Signal<StripeConfigurationData, Never>
  public let showErrorBanner: Signal<ErrorEnvelope, Never>

  public var inputs: PledgeRedemptionViewModelInputs { return self }
  public var outputs: PledgeRedemptionViewModelOutputs { return self }
}
