import KsApi
import Library
import Prelude
import UIKit

internal enum ProjectPamphletSubpage {
  case comments(Int, Bool)
  case updates(Int, Bool)

  internal var count: Int {
    switch self {
    case let .comments(count, _): return count
    case let .updates(count, _):  return count
    }
  }

  internal var isFirstInSection: Bool {
    switch self {
    case let .comments(_, isFirstInSection): return isFirstInSection
    case let .updates(_, isFirstInSection):  return isFirstInSection
    }
  }

  internal var isComments: Bool {
    switch self {
    case .comments: return true
    case .updates:  return false
    }
  }

  internal var isUpdates: Bool {
    switch self {
    case .comments: return false
    case .updates:  return true
    }
  }
}

internal final class ProjectPamphletSubpageCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var countContainerView: UIView!
  @IBOutlet private weak var countLabel: UILabel!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var subpageLabel: UILabel!
  @IBOutlet private weak var topGradientView: GradientView!

  internal func configureWith(value subpage: ProjectPamphletSubpage) {
    switch subpage {
    case .comments:
      self.subpageLabel.text = Strings.project_menu_buttons_comments()
    case .updates:
      self.subpageLabel.text = Strings.project_menu_buttons_updates()
    }

    self.countLabel.text = Format.wholeNumber(subpage.count)
    self.topGradientView.hidden = !subpage.isFirstInSection
    self.separatorView.hidden = !subpage.isFirstInSection
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> ProjectPamphletSubpageCell.lens.contentView.layoutMargins .~
        .init(topBottom: Styles.gridHalf(5), leftRight: Styles.gridHalf(7))

    self.countContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> UIView.lens.backgroundColor .~ .ksr_navy_300
      |> roundedStyle()

    self.countLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_headline(size: 13)

    self.rootStackView
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .EqualSpacing

    self.separatorView
      |> separatorStyle

    self.subpageLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_body(size: 14)

    self.topGradientView.startPoint = CGPoint(x: 0, y: 0)
    self.topGradientView.endPoint = CGPoint(x: 0, y: 1)
    self.topGradientView.setGradient([
      (UIColor.init(white: 0, alpha: 0.1), 0),
      (UIColor.init(white: 0, alpha: 0), 1)
    ])
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
    self.countContainerView.layer.cornerRadius = self.countContainerView.bounds.height / 2
  }
}
