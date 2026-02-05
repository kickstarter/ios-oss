import Foundation

public struct PledgePaymentMethodsAndSelectionData {
  public var existingPaymentMethods: [PledgePaymentMethodCellData]
  public var newPaymentMethods: [PledgePaymentMethodCellData]
  public var selectedPaymentMethod: PaymentSourceSelected? = nil
  public var isLoading: Bool
  public var shouldReload: Bool
}
