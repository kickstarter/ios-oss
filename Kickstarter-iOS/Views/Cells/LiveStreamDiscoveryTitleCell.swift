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
  case (.liveNow, _), (.upcoming, _), (.recentlyLive, _):
    return false
  }
}

internal final class LiveStreamDiscoveryTitleCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var liveIndicatorView: UIView!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var titleTypeLabel: UILabel!

  internal func configureWith(value: LiveStreamDiscoveryTitleType) {
    switch value {
    case .liveNow:
      self.titleTypeLabel.text = Strings.Live_now()
    case .recentlyLive:
      self.titleTypeLabel.text = Strings.Replay_past_live_streams()
    case .upcoming:
      self.titleTypeLabel.text = Strings.Upcoming_live_streams()
    }

    self.liveIndicatorView.isHidden = value != .liveNow
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { insets, cell in
        cell.traitCollection.isVerticallyCompact
          ? .init(top: Styles.grid(4), left: insets.left * 6, bottom: Styles.grid(2), right: insets.right)
          : .init(top: Styles.grid(4), left: insets.left, bottom: Styles.grid(2), right: insets.right)
    }

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.liveIndicatorView
      |> roundedStyle(cornerRadius: self.liveIndicatorView.frame.width / 2)
      |> UIView.lens.backgroundColor .~ .ksr_green_500

    _ = self.titleTypeLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_title3()
          : UIFont.ksr_title1(size: 18)
      }
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_900
  }
}
