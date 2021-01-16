public protocol IdentifyingTrackingClient {
  func identify(userId: String?, traits: [String: Any]?)
}
