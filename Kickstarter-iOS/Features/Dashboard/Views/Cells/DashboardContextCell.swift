import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardContextCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var containerView: UIView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var separatorView: UIView!
  @IBOutlet fileprivate var viewProjectButton: UIButton!

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> dashboardContextCellStyle
      |> UITableViewCell.lens.selectionStyle .~ .gray
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraits.button
      |> UITableViewCell.lens.accessibilityHint %~ { _ in
        Strings.dashboard_tout_accessibility_hint_opens_project()
      }

    _ = self.containerView
      |> containerViewBackgroundStyle

    _ = self.projectNameLabel
      |> dashboardStatTitleLabelStyle

    _ = self.separatorView
      |> separatorStyle

    _ = self.viewProjectButton
      |> dashboardViewProjectButtonStyle
      |> UIButton.lens.isUserInteractionEnabled .~ false
      |> UIButton.lens.accessibilityElementsHidden .~ true
  }

  internal func configureWith(value: Project) {
    self.projectNameLabel.text = value.name
  }
}
