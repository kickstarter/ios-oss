import Foundation
import KsApi
import Library
import Prelude

public protocol PledgeCreditCardCellViewModelInputs {
  func configureWith(_ value: GraphUserCreditCard.CreditCard)
}
