import Foundation
import KsApi

public enum FacebookCAPIEventName: String {
  /// viewing a project page
  case ProjectPageViewed = "ViewContent"
  /// viewing the reward selection screen
  case RewardSelectionViewed = "InitiateCheckout"
  /// viewing the checkout page where you enter credit card details
  case AddNewPaymentMethod = "AddPaymentInfo"
  /// completion of backing
  case BackingComplete = "Purchase"
}
