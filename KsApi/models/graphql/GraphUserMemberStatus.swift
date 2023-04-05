import Foundation
import Prelude

public struct GraphUserMemberStatus: Decodable {
  public var launchedProjectsTotalCount: Int
  public var memberProjectsTotalCount: Int
}

extension GraphUserMemberStatus: Equatable {
  public static func == (lhs: GraphUserMemberStatus, rhs: GraphUserMemberStatus) -> Bool {
    lhs.launchedProjectsTotalCount == rhs.launchedProjectsTotalCount &&
      lhs.memberProjectsTotalCount == rhs.memberProjectsTotalCount
  }
}
