public struct UserEnvelope<T: Decodable>: Decodable {
  public let me: T
}
