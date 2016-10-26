import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardVideoCell: UITableViewCell, ValueCell {
  private let viewModel: DashboardVideoCellViewModelType = DashboardVideoCellViewModel()

  @IBOutlet private weak var completionPercentageLabel: UILabel!
  @IBOutlet private weak var externalLabel: UILabel!
  @IBOutlet private weak var externalPlaysCountLabel: UILabel!
  @IBOutlet private weak var externalPlaysProgressView: UIView!
  @IBOutlet private weak var graphBackgroundView: UIView!
  @IBOutlet private weak var internalLabel: UILabel!
  @IBOutlet private weak var internalPlaysCountLabel: UILabel!
  @IBOutlet private weak var internalPlaysProgressView: UIView!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var statsContainerView: UIView!
  @IBOutlet private weak var totalPlaysContainerView: UIView!
  @IBOutlet private weak var totalPlaysCountLabel: UILabel!
  @IBOutlet private weak var totalPlaysStackView: UIStackView!
  @IBOutlet private weak var videoPlaysTitleLabel: UILabel!

  @IBOutlet private weak var graphStatsContainerView: UIView!
  @IBOutlet private weak var graphStatsStackView: UIStackView!

  internal override func bindStyles() {
    self
      |> baseTableViewCellStyle()

    self.completionPercentageLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 2

    self.externalLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 2

    self.externalPlaysProgressView
      |> dashboardVideoExternalPlaysProgressViewStyle

    self.externalPlaysCountLabel
      |> dashboardStatTitleLabelStyle

    self.graphStatsContainerView
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    self.graphBackgroundView
      |> containerViewBackgroundStyle
      |> UIView.lens.accessibilityElementsHidden .~ true

    self.graphStatsStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(1))

    self.internalLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.numberOfLines .~ 2

    self.internalPlaysProgressView
      |> dashboardVideoInternalPlaysProgressViewStyle

    self.internalPlaysCountLabel
      |> dashboardStatTitleLabelStyle

    self.separatorViews
      ||> separatorStyle

    self.statsContainerView
      |> dashboardCardStyle

    self.totalPlaysContainerView
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    self.totalPlaysCountLabel
      |> dashboardStatTitleLabelStyle

    self.totalPlaysStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.videoPlaysTitleLabel |> dashboardVideoPlaysTitleLabelStyle
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
      .observeNext { [weak element = externalPlaysProgressView] progress in
        let anchorY = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: 0.5, y: 1 - CGFloat(anchorY))
        element?.transform = CGAffineTransformMakeScale(1.0, CGFloat(progress))
    }

    self.viewModel.outputs.internalStartProgress
      .observeForUI()
      .observeNext { [weak element = internalPlaysProgressView] progress in
        let anchorY = progress == 0 ? 0 : 0.5 / progress
        element?.layer.anchorPoint = CGPoint(x: 0.5, y: 1 - CGFloat(anchorY))
        element?.transform = CGAffineTransformMakeScale(1.0, CGFloat(progress))
    }
  }

  internal func configureWith(value value: ProjectStatsEnvelope.VideoStats) {
    self.viewModel.inputs.configureWith(videoStats: value)
  }
}
