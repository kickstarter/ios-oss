import Foundation
import Prelude

public struct GraphUserMemberStatus: Decodable {
  public var creatorProjectsTotalCount: Int
  public var memberProjectsTotalCount: Int
}

extension GraphUserMemberStatus: Equatable {
  public static func == (lhs: GraphUserMemberStatus, rhs: GraphUserMemberStatus) -> Bool {
    lhs.creatorProjectsTotalCount == rhs.creatorProjectsTotalCount &&
      lhs.memberProjectsTotalCount == rhs.memberProjectsTotalCount
  }
}
