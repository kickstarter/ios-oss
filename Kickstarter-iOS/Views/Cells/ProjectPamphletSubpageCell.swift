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
    self.setNeedsLayout()
    self.attachLiveNowAnimation()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> ProjectPamphletSubpageCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
      |> ProjectPamphletSubpageCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.gridHalf(5), leftRight: Styles.grid(16))
          : .init(topBottom: Styles.gridHalf(5), leftRight: Styles.gridHalf(7))
    }

    _ = self.countContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> roundedStyle()
      |> UIView.lens.layer.borderWidth .~ 1

    _ = self.countLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UIView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityRequired
      |> UIView.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityRequired

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill

    _ = self.liveNowImageView
      |> UIImageView.lens.tintColor .~ .ksr_green_500
      |> UIImageView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityRequired
      |> UIImageView.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityRequired

    _ = self.separatorView
      |> separatorStyle

    _ = self.subpageLabel
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UIView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultLow
      |> UIView.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultLow

    self.topGradientView.startPoint = CGPoint(x: 0, y: 0)
    self.topGradientView.endPoint = CGPoint(x: 0, y: 1)
    self.topGradientView.setGradient([
      (UIColor.init(white: 0, alpha: 0.1), 0),
      (UIColor.init(white: 0, alpha: 0), 1)
    ])

    self.setNeedsLayout()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.countLabel.rac.text = self.viewModel.outputs.countLabelText
    self.countLabel.rac.textColor = self.viewModel.outputs.countLabelTextColor
    self.countContainerView.rac.backgroundColor = self.viewModel.outputs.countLabelBackgroundColor

    self.viewModel.outputs.countLabelBorderColor
      .observeForUI()
      .observeValues { [weak self] in
        self?.countContainerView.layer.borderColor = $0.cgColor
    }

    self.liveNowImageView.rac.hidden = self.viewModel.outputs.liveNowImageViewHidden
    self.topGradientView.rac.hidden = self.viewModel.outputs.topGradientViewHidden
    self.separatorView.rac.hidden = self.viewModel.outputs.separatorViewHidden

    self.subpageLabel.rac.text = self.viewModel.outputs.labelText
    self.subpageLabel.rac.textColor = self.viewModel.outputs.labelTextColor

    self.viewModel.outputs.opacityForViews
      .observeForUI()
      .observeValues { [weak self] alpha in
        guard let _self = self else { return }
        UIView.animate(withDuration: (alpha == 0 ? 0.0 : 0.2), delay: 0.0, options: .curveEaseOut,
                       animations: {
                        _self.subpageLabel.alpha = alpha
                        _self.countLabel.alpha = alpha
                        _self.countContainerView.alpha = alpha
        },
                       completion: nil)
    }
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
    self.countContainerView.layer.cornerRadius = self.countContainerView.bounds.height / 2
  }

  // Animates the live now icon in a pulsating fashion...
  private func attachLiveNowAnimation() {
    let fadeAlpha: CGFloat = 0.2
    let fadeTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)

    self.liveNowImageView.alpha = 1
    self.liveNowImageView.transform = .identity

    UIView.animateKeyframes(
      withDuration: 2,
      delay: 0,
      options: [.autoreverse, .repeat, .calculationModeCubic],
      animations: { [weak v = self.liveNowImageView] in

        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
          v?.alpha = fadeAlpha
          v?.transform = fadeTransform
        }

        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.4) {
          v?.alpha = 1
          v?.transform = .identity
        }

        UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
        }

      }, completion: nil)
  }
}
