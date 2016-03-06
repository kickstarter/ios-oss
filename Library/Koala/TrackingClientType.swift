public protocol TrackingClientType {
  /**
   Tracks an event in our analytics system.

   - parameter event:      Name of the event.
   - parameter properties: Dictionary of properties associated with event.
   */
  func track(event event: String, properties: [String:AnyObject])
}

public extension TrackingClientType {
  /**
   Tracks an event in our analytics system.

   - parameter event: Name of the event.
   */
  public func track(event event: String) {
    self.track(event: event, properties: [:])
  }
}
