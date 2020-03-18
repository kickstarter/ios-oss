import Foundation

public enum PledgeViewContext {
  case fixPaymentMethod
  case pledge
  case update
  case changePaymentMethod
  case updateReward

  var confirmationLabelHidden: Bool {
    switch self {
    case .fixPaymentMethod, .changePaymentMethod, .updateReward: return true
    case .pledge, .update: return false
    }
  }

  var continueViewHidden: Bool {
    switch self {
    case .pledge: return false
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward: return true
    }
  }

  var descriptionViewHidden: Bool {
    switch self {
    case .pledge, .updateReward: return false
    case .fixPaymentMethod, .update, .changePaymentMethod: return true
    }
  }

  var isCreating: Bool {
    switch self {
    case .pledge: return true
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward: return false
    }
  }

  var isUpdating: Bool {
    switch self {
    case .pledge: return false
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward: return true
    }
  }

  var paymentMethodsViewHidden: Bool {
    switch self {
    case .fixPaymentMethod, .pledge, .changePaymentMethod: return false
    case .update, .updateReward: return true
    }
  }

  var pledgeAmountViewHidden: Bool {
    switch self {
    case .pledge, .update, .updateReward: return false
    case .fixPaymentMethod, .changePaymentMethod: return true
    }
  }

  var pledgeAmountSummaryViewHidden: Bool {
    switch self {
    case .fixPaymentMethod, .changePaymentMethod: return false
    case .pledge, .update, .updateReward: return true
    }
  }

  var sectionSeparatorsHidden: Bool {
    switch self {
    case .pledge, .updateReward: return false
    case .fixPaymentMethod, .update, .changePaymentMethod: return true
    }
  }

  var shippingLocationViewHidden: Bool {
    switch self {
    case .pledge, .update, .updateReward: return false
    case .fixPaymentMethod, .changePaymentMethod: return true
    }
  }

  var submitButtonTitle: String {
    switch self {
    case .pledge: return Strings.Pledge()
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward: return Strings.Confirm()
    }
  }

  var title: String {
    switch self {
    case .fixPaymentMethod: return Strings.Fix_payment_method()
    case .pledge: return Strings.Back_this_project()
    case .update, .updateReward: return Strings.Update_pledge()
    case .changePaymentMethod: return Strings.Change_payment_method()
    }
  }
}
