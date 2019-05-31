import KsApi
import PassKit

public struct PaymentData: Equatable {
  public let tokenData: PaymentTokenData
}

public struct PaymentTokenData: Equatable {
  public let paymentMethodData: PaymentMethodData
  public let transactionIdentifier: String
}

public struct PaymentMethodData: Equatable {
  public let displayName: String?
  public let network: PKPaymentNetwork?
  public let type: PKPaymentMethodType
}

extension PaymentData {
  public init(payment: PKPayment) {
    self = .init(
      tokenData: .init(
        paymentMethodData: .init(
          displayName: payment.token.paymentMethod.displayName,
          network: payment.token.paymentMethod.network,
          type: payment.token.paymentMethod.type
        ),
        transactionIdentifier: payment.token.transactionIdentifier
      )
    )
  }
}

extension PaymentMethodData {
  public init(paymentMethod: PKPaymentMethod) {
    self = .init(
      displayName: paymentMethod.displayName,
      network: paymentMethod.network,
      type: paymentMethod.type
    )
  }
}
