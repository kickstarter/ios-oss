import Foundation

public struct Checkout: Decodable {
  public var state: State

  public enum State: String, Decodable, CaseIterable {
    case authorizing = "AUTHORIZING"
    case verifying = "VERIFYING"
    case successful = "SUCCESSFUL"
    case failed = "FAILED"
  }
}

extension Checkout {
  enum CodingKeys: String, CodingKey {
    case state
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.state = try values.decode(State.self, forKey: .state)
  }
}
