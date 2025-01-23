import KsApi

public struct PPOUserSettings: EncodableType, Decodable, Equatable {
  public let hasAction: Bool

  public init(hasAction: Bool) {
    self.hasAction = hasAction
  }

  public func encode() -> [String: Any] {
    return ["hasAction": self.hasAction]
  }
}
