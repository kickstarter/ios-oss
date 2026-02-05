import Foundation
import Prelude

public struct GraphUserEmail: Decodable {
  public var email: String? = nil
}

extension GraphUserEmail: Equatable {
  public static func == (lhs: GraphUserEmail, rhs: GraphUserEmail) -> Bool {
    lhs.email == rhs.email
  }
}
