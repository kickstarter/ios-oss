// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension GraphAPI {
  /// All available states for a checkout
  enum CheckoutState: String, EnumType {
    case authorizing = "AUTHORIZING"
    case verifying = "VERIFYING"
    case successful = "SUCCESSFUL"
    case failed = "FAILED"
  }

}