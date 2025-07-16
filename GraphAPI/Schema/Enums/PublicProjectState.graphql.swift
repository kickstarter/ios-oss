// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Publically visible project states.
public enum PublicProjectState: String, EnumType {
  /// Active and accepting pledges.
  case live = "LIVE"
  /// Successfully funded by deadline.
  case successful = "SUCCESSFUL"
  /// Failed to fund by deadline.
  case failed = "FAILED"
  /// Project is submitted and in prelaunch state.
  case submitted = "SUBMITTED"
  /// Project that is in prelaunch.
  case upcoming = "UPCOMING"
  /// Project that is successful and accepting late pledges.
  case latePledge = "LATE_PLEDGE"
}
