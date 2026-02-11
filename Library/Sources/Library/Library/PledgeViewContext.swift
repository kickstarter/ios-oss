import Foundation

public enum PledgeViewContext {
  case changePaymentMethod
  case editPledgeOverTime
  case fixPaymentMethod
  case latePledge
  case pledge
  case update
  case updateReward

  var confirmationLabelHidden: Bool {
    switch self {
    case .fixPaymentMethod, .changePaymentMethod, .updateReward, .editPledgeOverTime: return true
    case .pledge, .latePledge, .update: return false
    }
  }

  var continueViewHidden: Bool {
    switch self {
    case .pledge, .latePledge: return false
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward, .editPledgeOverTime: return true
    }
  }

  var descriptionViewHidden: Bool {
    switch self {
    case .pledge, .latePledge, .updateReward, .editPledgeOverTime: return false
    case .fixPaymentMethod, .update, .changePaymentMethod: return true
    }
  }

  var expandableRewardViewHidden: Bool {
    switch self {
    case .pledge, .latePledge, .updateReward, .editPledgeOverTime: return false
    case .fixPaymentMethod, .update, .changePaymentMethod: return true
    }
  }

  var isCreating: Bool {
    switch self {
    case .pledge, .latePledge: return true
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward, .editPledgeOverTime: return false
    }
  }

  var isUpdating: Bool {
    switch self {
    case .pledge, .latePledge: return false
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward, .editPledgeOverTime: return true
    }
  }

  var paymentMethodsViewHidden: Bool {
    switch self {
    case .fixPaymentMethod, .pledge, .latePledge, .changePaymentMethod: return false
    case .update, .updateReward, .editPledgeOverTime: return true
    }
  }

  var pledgeAmountViewHidden: Bool {
    switch self {
    case .pledge, .latePledge, .update, .updateReward, .editPledgeOverTime: return false
    case .fixPaymentMethod, .changePaymentMethod: return true
    }
  }

  var pledgeAmountSummaryViewHidden: Bool {
    switch self {
    case .fixPaymentMethod, .changePaymentMethod, .update, .editPledgeOverTime: return false
    case .pledge, .latePledge, .updateReward: return true
    }
  }

  var sectionSeparatorsHidden: Bool {
    switch self {
    case .pledge, .latePledge, .updateReward, .editPledgeOverTime: return false
    case .fixPaymentMethod, .update, .changePaymentMethod: return true
    }
  }

  var shippingLocationViewHidden: Bool {
    switch self {
    case .pledge, .latePledge, .update, .updateReward, .editPledgeOverTime: return false
    case .fixPaymentMethod, .changePaymentMethod: return true
    }
  }

  var applePayButtonHidden: Bool {
    switch self {
    case .pledge, .latePledge, .fixPaymentMethod, .changePaymentMethod: return false
    case .update, .updateReward, .editPledgeOverTime: return true
    }
  }

  var submitButtonTitle: String {
    switch self {
    case .pledge, .latePledge: return Strings.Pledge()
    case .fixPaymentMethod, .update, .changePaymentMethod, .updateReward,
         .editPledgeOverTime: return Strings.Confirm()
    }
  }

  var title: String {
    switch self {
    case .fixPaymentMethod: return Strings.Fix_payment_method()
    case .pledge, .latePledge: return Strings.Back_this_project()
    case .update, .updateReward, .editPledgeOverTime: return Strings.Update_pledge()
    case .changePaymentMethod: return Strings.Change_payment_method()
    }
  }
}
