import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ActivityFriendBackingCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityFriendBackingViewModel = ActivityFriendBackingViewModel()

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var friendImageView: UIImageView!
  @IBOutlet private weak var friendTitleLabel: UILabel!
  @IBOutlet private weak var fundingProgressBarView: UIView!
  @IBOutlet private weak var fundingProgressContainerView: UIView!
  @IBOutlet private weak var fundingProgressLabel: UILabel!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var projectTextContainerView: UIView!

  func configureWith(value value: Activity) {
    self.viewModel.inputs.configureWith(activity: value)
  }

  override func bindViewModel() {
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
    self.friendTitleLabel.rac.attributedText = self.viewModel.outputs.friendTitle
    self.fundingProgressBarView.rac.backgroundColor = self.viewModel.outputs.fundingBarColor
    self.fundingProgressLabel.rac.attributedText = self.viewModel.outputs.percentFundedText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(next: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
        friendImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak friendImageView] url in
        friendImageView?.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.2))
    }

    self.viewModel.outputs.fundingProgressPercentage
      .observeForUI()
      .observeNext { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak projectImageView] url in
        projectImageView?.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.2))
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(30))
          : .init(topBottom: Styles.gridHalf(3), leftRight: Styles.grid(2))
    }

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
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3) - Styles.gridHalf(1), leftRight: Styles.grid(2))
  }
}
