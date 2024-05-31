import Foundation

public struct PledgePaymentMethodsAndSelectionData {
  public var paymentMethodsCellData: [PledgePaymentMethodCellData]
  public var paymentSheetPaymentMethodsCellData: [PaymentSheetPaymentMethodCellData]
  public var selectedPaymentMethod: PaymentSourceSelected?
  public var isLoading: Bool
  public var shouldReload: Bool
}
