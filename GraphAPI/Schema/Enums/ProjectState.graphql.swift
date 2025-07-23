// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Various project states.
public enum ProjectState: String, EnumType {
  /// Created and preparing for launch.
  case started = "STARTED"
  /// Ready for launch with a draft submitted for auto-approval.
  case submitted = "SUBMITTED"
  /// Active and accepting pledges.
  case live = "LIVE"
  /// Canceled by creator.
  case canceled = "CANCELED"
  /// Suspended for investigation, visible.
  case suspended = "SUSPENDED"
  /// Suspended and hidden.
  case purged = "PURGED"
  /// Successfully funded by deadline.
  case successful = "SUCCESSFUL"
  /// Failed to fund by deadline.
  case failed = "FAILED"
}
