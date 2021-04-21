public protocol IdentifyingTrackingClient {
  /**
   Identifies a user for event tracking, using the Segment SDK.

   - parameter userId: The userId associated with this user on Segment.
   - parameter traits: Dictionary of properties associated with event.
   */
  func identify(_ userId: String?, traits: [String: Any]?)

  /**
   Resets the identity of a user with Segment.
   */
  func reset()
}
