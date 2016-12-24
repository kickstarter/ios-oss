import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ActivityFriendBackingCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivityFriendBackingViewModel = ActivityFriendBackingViewModel()

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var friendImageView: UIImageView!
  @IBOutlet fileprivate weak var friendTitleLabel: UILabel!
  @IBOutlet fileprivate weak var fundingProgressBarView: UIView!
  @IBOutlet fileprivate weak var fundingProgressContainerView: UIView!
  @IBOutlet fileprivate weak var fundingProgressLabel: UILabel!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectTextContainerView: UIView!

  func configureWith(value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  override func bindViewModel() {
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.friendTitleLabel.rac.attributedText = self.viewModel.outputs.friendTitle
    self.fundingProgressBarView.rac.backgroundColor = self.viewModel.outputs.fundingBarColor
    self.fundingProgressLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(event: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
        friendImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak friendImageView] url in
        friendImageView?.ksr_setImageWithURL(url)
    }

    self.viewModel.outputs.fundingProgressPercentage
      .observeForUI()
      .observeValues { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransform(scaleX: CGFloat(progress), y: 1.0)
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak projectImageView] url in
        projectImageView?.ksr_setImageWithURL(url)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> feedTableViewCellStyle
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    self.cardView
      |> dropShadowStyle()

    self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_400

    self.projectImageView
      |> UIImageView.lens.clipsToBounds .~ true

    self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 18)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.projectTextContainerView
      |> UIView.lens.alpha .~ 0.96
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3) - Styles.gridHalf(1),
                                            leftRight: Styles.grid(2))
  }
}
