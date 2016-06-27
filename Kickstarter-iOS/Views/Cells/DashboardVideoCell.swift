import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardVideoCell: UITableViewCell, ValueCell {
  private let viewModel: DashboardVideoCellViewModelType = DashboardVideoCellViewModel()

  @IBOutlet private weak var completionPercentageLabel: UILabel!
  @IBOutlet private weak var externalPlaysCountLabel: UILabel!
  @IBOutlet private weak var externalPlaysProgressView: UIView!
  @IBOutlet private weak var internalPlaysCountLabel: UILabel!
  @IBOutlet private weak var internalPlaysProgressView: UIView!
  @IBOutlet private weak var totalPlaysCountLabel: UILabel!
  @IBOutlet private weak var videoPlaysTitleLabel: UILabel!

  internal override func bindStyles() {
    self |> baseTableViewCellStyle()
    self.completionPercentageLabel |> dashboardVideoCompletionPercentageLabelStyle
    self.externalPlaysCountLabel |> dashboardVideoExternalPlayCountLabelStyle
    self.externalPlaysProgressView |> UIView.lens.backgroundColor .~ .ksr_darkGray
    self.internalPlaysCountLabel |> dashboardVideoInternalPlayCountLabelStyle
    self.internalPlaysProgressView |> UIView.lens.backgroundColor .~ .ksr_green
    self.totalPlaysCountLabel |> dashboardVideoTotalPlaysCountLabelStyle
    self.videoPlaysTitleLabel |> dashboardVideoPlaysTitleLabelStyle
  }

  internal override func bindViewModel() {
    self.completionPercentageLabel.rac.text = self.viewModel.outputs.completionPercentage
    self.externalPlaysCountLabel.rac.text = self.viewModel.outputs.externalStartCount
    self.internalPlaysCountLabel.rac.text = self.viewModel.outputs.internalStartCount
    self.totalPlaysCountLabel.rac.text = self.viewModel.outputs.totalStartCount

    self.viewModel.outputs.externalStartProgress
      .observeForUI()
      .observeNext { [weak element = externalPlaysProgressView] progress in
        element?.layer.anchorPoint = CGPoint(x: CGFloat(0.5 / progress), y: 0.5)
        element?.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }

    self.viewModel.outputs.internalStartProgress
      .observeForUI()
      .observeNext { [weak element = internalPlaysProgressView] progress in
        element?.layer.anchorPoint = CGPoint(x: CGFloat(0.5 / progress), y: 0.5)
        element?.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }
  }

  internal func configureWith(value value: ProjectStatsEnvelope.VideoStats) {
    self.viewModel.inputs.configureWith(videoStats: value)
  }
}
