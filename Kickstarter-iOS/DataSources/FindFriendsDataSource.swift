import Library
import KsApi
import UIKit

internal final class FindFriendsDataSource: ValueCellDataSource {
  private enum Section: Int {
    case FacebookConnect
    case Stats
    case Friends
  }

  internal func facebookConnect(source source: FriendsSource, visible: Bool) {
    self.set(values: visible ? [source] : [],
             cellClass: FindFriendsFacebookConnectCell.self,
             inSection: Section.FacebookConnect.rawValue)
  }

  internal func stats(stats stats: FriendStatsEnvelope, source: FriendsSource) {
    self.set(values: [(stats, source)],
             cellClass: FindFriendsStatsCell.self,
             inSection: Section.Stats.rawValue)
  }

  internal func friends(friends: [User], source: FriendsSource) {
    let friendAndSource = friends.map { (friend: $0, source: source) }

    self.set(values: friendAndSource,
             cellClass: FindFriendsFriendFollowCell.self,
             inSection: Section.Friends.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as FindFriendsStatsCell, value as (FriendStatsEnvelope, FriendsSource)):
      cell.configureWith(value: value)
    case let (cell as FindFriendsFriendFollowCell, value as (User, FriendsSource)):
      cell.configureWith(value: value)
    case let (cell as FindFriendsFacebookConnectCell, value as FriendsSource):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
