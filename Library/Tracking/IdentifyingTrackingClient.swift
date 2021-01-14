public protocol IdentifyingTrackingClient {
  func identify(_ userId: String?, traits: [String: Any]?)
}
