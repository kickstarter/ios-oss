// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension GraphAPI {
  /// Various backing states.
  enum BackingState: String, EnumType {
    case preauth = "preauth"
    case pledged = "pledged"
    case canceled = "canceled"
    case collected = "collected"
    case errored = "errored"
    case authenticationRequired = "authentication_required"
    case dropped = "dropped"
    case dummy = "dummy"
  }

}