import Library
import Prelude

internal enum LiveStreamDiscoveryTitleType {
  case liveNow
  case recentlyLive
  case upcoming
}

extension LiveStreamDiscoveryTitleType: Equatable {
}
internal func == (lhs: LiveStreamDiscoveryTitleType, rhs: LiveStreamDiscoveryTitleType) -> Bool {
  switch (lhs, rhs) {
  case (.liveNow, .liveNow), (.upcoming, .upcoming), (.recentlyLive, .recentlyLive):
    return true
  default:
    return false
  }
}

internal final class LiveStreamDiscoveryTitleCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var titleTypeLabel: UILabel!

  internal func configureWith(value: LiveStreamDiscoveryTitleType) {
    switch value {
    case .liveNow:
      self.titleTypeLabel.text = "Live now!"
    case .recentlyLive:
      self.titleTypeLabel.text = "Recently live"
    case .upcoming:
      self.titleTypeLabel.text = "Upcoming!"
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
  }
}
