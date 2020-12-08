import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletSubpageCell: UITableViewCell, ValueCell {
  @IBOutlet private var countContainerView: UIView!
  @IBOutlet private var countLabel: UILabel!
  @IBOutlet private var rootStackView: UIStackView!
  @IBOutlet private var separatorView: UIView!
  @IBOutlet private var subpageLabel: UILabel!
  @IBOutlet private var topSeparatorView: UIView!

  private let viewModel: ProjectPamphletSubpageCellViewModelType = ProjectPamphletSubpageCellViewModel()

  internal func configureWith(value subpage: ProjectPamphletSubpage) {
    self.viewModel.inputs.configureWith(subpage: subpage)
    self.setNeedsLayout()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectPamphletSubpageCell.lens.accessibilityTraits .~ UIAccessibilityTraits.button
      |> ProjectPamphletSubpageCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.gridHalf(5), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.gridHalf(5), leftRight: Styles.gridHalf(7))
      }

    _ = self.countContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> UIView.lens.layer.borderWidth .~ 1

    _ = self.countLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UIView.lens.contentHuggingPriority(for: .horizontal) .~ UILayoutPriority.required
      |> UIView.lens.contentCompressionResistancePriority(for: .horizontal) .~ UILayoutPriority.required

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill

    _ = [self.separatorView, self.topSeparatorView]
      ||> separatorStyle

    _ = self.subpageLabel
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.backgroundColor .~ .ksr_white
      |> UIView.lens.contentHuggingPriority(for: .horizontal) .~ UILayoutPriority.defaultLow
      |> UIView.lens.contentCompressionResistancePriority(for: .horizontal) .~ UILayoutPriority.defaultLow

    self.setNeedsLayout()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.countLabel.rac.text = self.viewModel.outputs.countLabelText
    self.countLabel.rac.textColor = self.viewModel.outputs.countLabelTextColor
    self.countLabel.rac.backgroundColor = self.viewModel.outputs.countLabelBackgroundColor
    self.countContainerView.rac.backgroundColor = self.viewModel.outputs.countLabelBackgroundColor

    self.viewModel.outputs.countLabelBorderColor
      .observeForUI()
      .observeValues { [weak self] in
        self?.countContainerView.layer.borderColor = $0.cgColor
      }

    self.topSeparatorView.rac.hidden = self.viewModel.outputs.topSeparatorViewHidden
    self.separatorView.rac.hidden = self.viewModel.outputs.separatorViewHidden

    self.subpageLabel.rac.text = self.viewModel.outputs.labelText
    self.subpageLabel.rac.textColor = self.viewModel.outputs.labelTextColor
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
  }
}
