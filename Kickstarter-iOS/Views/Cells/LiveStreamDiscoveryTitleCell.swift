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
      self.titleTypeLabel.text = localizedString(key: "Live_now",
                                                 defaultValue: "Live now!")
    case .recentlyLive:
      self.titleTypeLabel.text = localizedString(key: "Recently_live",
                                                 defaultValue: "Recently live")
    case .upcoming:
      self.titleTypeLabel.text = localizedString(key: "Upcoming",
                                                 defaultValue: "Upcoming!")
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { insets, cell in
        cell.traitCollection.isVerticallyCompact
          ? .init(top: Styles.grid(4), left: insets.left * 8, bottom: Styles.grid(2), right: insets.right)
          : .init(top: Styles.grid(4), left: insets.left * 2, bottom: Styles.grid(2), right: insets.right)
    }
  }
}
