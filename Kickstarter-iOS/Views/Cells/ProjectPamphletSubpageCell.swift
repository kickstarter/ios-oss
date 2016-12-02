import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectPamphletSubpageCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var countContainerView: UIView!
  @IBOutlet private weak var countLabel: UILabel!
  @IBOutlet private weak var liveNowImageView: UIImageView!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var subpageLabel: UILabel!
  @IBOutlet private weak var topGradientView: GradientView!

  private let viewModel: ProjectPamphletSubpageCellViewModelType = ProjectPamphletSubpageCellViewModel()

  internal func configureWith(value subpage: ProjectPamphletSubpage) {
    self.viewModel.inputs.configureWith(subpage: subpage)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> ProjectPamphletSubpageCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
      |> ProjectPamphletSubpageCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.gridHalf(5), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.gridHalf(5), leftRight: Styles.gridHalf(7))
    }

    self.countContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> roundedStyle()
      |> UIView.lens.layer.borderWidth .~ 1

    self.countLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)

    self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .Fill

    self.separatorView
      |> separatorStyle

    self.subpageLabel
      |> UILabel.lens.font .~ .ksr_body(size: 14)

    self.topGradientView.startPoint = CGPoint(x: 0, y: 0)
    self.topGradientView.endPoint = CGPoint(x: 0, y: 1)
    self.topGradientView.setGradient([
      (UIColor.init(white: 0, alpha: 0.1), 0),
      (UIColor.init(white: 0, alpha: 0), 1)
    ])
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.countLabel.rac.text = self.viewModel.outputs.countLabelText
    self.countLabel.rac.textColor = self.viewModel.outputs.countLabelTextColor
    self.countContainerView.rac.backgroundColor = self.viewModel.outputs.countLabelBackgroundColor

    self.viewModel.outputs.countLabelBorderColor.observeNext { [weak self] in
      self?.countContainerView.layer.borderColor = $0.CGColor
    }

    self.liveNowImageView.rac.hidden = self.viewModel.outputs.liveNowImageViewHidden
    self.topGradientView.rac.hidden = self.viewModel.outputs.topGradientViewHidden
    self.separatorView.rac.hidden = self.viewModel.outputs.separatorViewHidden

    self.subpageLabel.rac.text = self.viewModel.outputs.labelText
    self.subpageLabel.rac.textColor = self.viewModel.outputs.labelTextColor
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
    self.countContainerView.layer.cornerRadius = self.countContainerView.bounds.height / 2
  }
}
