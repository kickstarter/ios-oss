import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardContextCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var viewProjectButton: UIButton!

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> dashboardContextCellStyle
      |> UITableViewCell.lens.selectionStyle .~ .gray
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.dashboard_tout_accessibility_hint_opens_project() }

    self.containerView
      |> containerViewBackgroundStyle

    self.projectNameLabel
      |> dashboardStatTitleLabelStyle

    self.separatorView
      |> separatorStyle

    self.viewProjectButton
      |> dashboardViewProjectButtonStyle
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.accessibilityElementsHidden .~ true
  }

  internal func configureWith(value: Project) {
    self.projectNameLabel.text = value.name
  }
}
