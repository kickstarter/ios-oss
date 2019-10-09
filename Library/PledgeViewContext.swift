import Foundation

public enum PledgeViewContext {
  case pledge
  case update
  case changePaymentMethod

  var confirmationLabelHidden: Bool {
    switch self {
    case .pledge, .changePaymentMethod: return true
    case .update: return false
    }
  }

  var continueViewHidden: Bool {
    switch self {
    case .pledge: return false
    case .update, .changePaymentMethod: return true
    }
  }

  var descriptionViewHidden: Bool {
    switch self {
    case .pledge: return false
    case .update, .changePaymentMethod: return true
    }
  }

  var isCreating: Bool {
    switch self {
    case .pledge: return true
    case .update, .changePaymentMethod: return false
    }
  }

  var isUpdating: Bool {
    switch self {
    case .pledge: return false
    case .update, .changePaymentMethod: return true
    }
  }

  var paymentMethodsViewHidden: Bool {
    switch self {
    case .pledge, .changePaymentMethod: return false
    case .update: return true
    }
  }

  var sectionSeparatorsHidden: Bool {
    switch self {
    case .pledge: return false
    case .update, .changePaymentMethod: return true
    }
  }

  var submitButtonTitle: String {
    switch self {
    case .pledge: return Strings.Pledge()
    case .update, .changePaymentMethod: return Strings.Confirm()
    }
  }

  var title: String {
    switch self {
    case .pledge: return Strings.Back_this_project()
    case .update: return Strings.Update_pledge()
    case .changePaymentMethod: return Strings.Change_payment_method()
    }
  }
}
