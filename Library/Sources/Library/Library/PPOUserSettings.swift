import KsApi

public struct PPOUserSettings: EncodableType, Decodable, Equatable {
  public let hasAction: Bool
  public let backingActionCount: Int

  public init(hasAction: Bool, backingActionCount: Int) {
    self.hasAction = hasAction
    self.backingActionCount = backingActionCount
  }

  public func encode() -> [String: Any] {
    return [
      "hasAction": self.hasAction,
      "backingActionCount": self.backingActionCount
    ]
  }
}
