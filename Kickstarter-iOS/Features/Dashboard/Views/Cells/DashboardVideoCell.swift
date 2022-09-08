import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardVideoCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: DashboardVideoCellViewModelType = DashboardVideoCellViewModel()

  @IBOutlet fileprivate var completionPercentageLabel: UILabel!
  @IBOutlet fileprivate var externalLabel: UILabel!
  @IBOutlet fileprivate var externalPlaysCountLabel: UILabel!
  @IBOutlet fileprivate var externalPlaysProgressView: UIView!
  @IBOutlet fileprivate var graphBackgroundView: UIView!
  @IBOutlet fileprivate var internalLabel: UILabel!
  @IBOutlet fileprivate var internalPlaysCountLabel: UILabel!
  @IBOutlet fileprivate var internalPlaysProgressView: UIView!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate var statsContainerView: UIView!
  @IBOutlet fileprivate var totalPlaysContainerView: UIView!
  @IBOutlet fileprivate var totalPlaysCountLabel: UILabel!
  @IBOutlet fileprivate var totalPlaysStackView: UIStackView!
  @IBOutlet fileprivate var videoPlaysTitleLabel: UILabel!

  @IBOutlet fileprivate var graphStatsContainerView: UIView!
  @IBOutlet fileprivate var graphStatsStackView: UIStackView!

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.completionPercentageLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.externalLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.externalPlaysProgressView
      |> dashboardVideoExternalPlaysProgressViewStyle

    _ = self.externalPlaysCountLabel
      |> dashboardStatTitleLabelStyle

    _ = self.graphStatsContainerView
      |> UIView.lens.backgroundColor .~ .ksr_support_100

    _ = self.graphBackgroundView
      |> containerViewBackgroundStyle
      |> UIView.lens.accessibilityElementsHidden .~ true

    _ = self.graphStatsStackView
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(1))

    _ = self.internalLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.internalPlaysProgressView
      |> dashboardVideoInternalPlaysProgressViewStyle

    _ = self.internalPlaysCountLabel
      |> dashboardStatTitleLabelStyle

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.statsContainerView
      |> dashboardCardStyle

    _ = self.totalPlaysContainerView
      |> UIView.lens.backgroundColor .~ .ksr_support_100

    _ = self.totalPlaysCountLabel
      |> dashboardStatTitleLabelStyle

    _ = self.totalPlaysStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.videoPlaysTitleLabel |> dashboardVideoPlaysTitleLabelStyle
  }

  internal override func bindViewModel() {
    self.completionPercentageLabel.rac.text = self.viewModel.outputs.completionPercentage
    self.externalPlaysCountLabel.rac.text = self.viewModel.outputs.externalStartCount
    self.internalPlaysCountLabel.rac.text = self.viewModel.outputs.internalStartCount
    self.internalLabel.rac.text = self.viewModel.outputs.internalText
    self.externalLabel.rac.text = self.viewModel.outputs.externalText
    self.totalPlaysCountLabel.rac.attributedText = self.viewModel.outputs.totalStartCount

    self.viewModel.outputs.externalStartProgress
      .observeForUI()
      .observeValues { [weak element = externalPlaysProgressView] progress in
        let anchorY = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: 0.5, y: 1 - CGFloat(anchorY))
        element?.transform = CGAffineTransform(scaleX: 1.0, y: CGFloat(progress))
      }

    self.viewModel.outputs.internalStartProgress
      .observeForUI()
      .observeValues { [weak element = internalPlaysProgressView] progress in
        let anchorY = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: 0.5, y: 1 - CGFloat(anchorY))
        element?.transform = CGAffineTransform(scaleX: 1.0, y: CGFloat(progress))
      }
  }

  internal func configureWith(value: ProjectStatsEnvelope.VideoStats) {
    self.viewModel.inputs.configureWith(videoStats: value)
  }
}
