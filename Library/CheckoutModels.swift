import KsApi
import PassKit

public struct PaymentData {
  public let tokenData: PaymentTokenData
}

public struct PaymentTokenData {
  public let paymentMethodData: PaymentMethodData
  public let transactionIdentifier: String
}

public struct PaymentMethodData {
  public let displayName: String?
  public let network: String?
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

extension PaymentData: Equatable {}
public func == (lhs: PaymentData, rhs: PaymentData) -> Bool {
  return lhs.tokenData == rhs.tokenData
}

extension PaymentTokenData: Equatable {}
public func == (lhs: PaymentTokenData, rhs: PaymentTokenData) -> Bool {
  return lhs.paymentMethodData == rhs.paymentMethodData
    && lhs.transactionIdentifier == rhs.transactionIdentifier
}

extension PaymentMethodData: Equatable {}
public func == (lhs: PaymentMethodData, rhs: PaymentMethodData) -> Bool {
  return lhs.displayName == rhs.displayName
    && lhs.network == rhs.network
    && lhs.type == rhs.type
}
