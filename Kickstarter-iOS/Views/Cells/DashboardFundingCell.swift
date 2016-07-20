import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardFundingCell: UITableViewCell, ValueCell {
  private let viewModel: DashboardFundingCellViewModelType = DashboardFundingCellViewModel()

  @IBOutlet private weak var backersTitleLabel: UILabel!
  @IBOutlet private weak var backersSubtitleLabel: UILabel!
  @IBOutlet private weak var deadlineDateLabel: UILabel!
  @IBOutlet private weak var fundingProgressTitleLabel: UILabel!
  @IBOutlet private weak var graphAxisSeparatorView: UIView!
  @IBOutlet private weak var graphBackgroundView: UIView!
  @IBOutlet private weak var graphView: FundingGraphView!
  @IBOutlet private weak var graphXAxisStackView: UIStackView!
  @IBOutlet private weak var graphYAxisBottomLabel: UILabel!
  @IBOutlet private weak var graphYAxisMiddleLabel: UILabel!
  @IBOutlet private weak var graphYAxisTopLabel: UILabel!
  @IBOutlet private weak var launchDateLabel: UILabel!
  @IBOutlet private weak var pledgedSubtitleLabel: UILabel!
  @IBOutlet private weak var pledgedTitleLabel: UILabel!
  @IBOutlet var separatorViews: [UIView]!
  @IBOutlet private weak var statsStackView: UIStackView!
  @IBOutlet private weak var timeRemainingSubtitleLabel: UILabel!
  @IBOutlet private weak var timeRemainingTitleLabel: UILabel!

  internal override func bindStyles() {
    super.bindStyles()

    self.accessibilityLabel = Strings.dashboard_graphs_funding_title_funding_progress()
    self |> baseTableViewCellStyle()
    self.backersSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_tout_backers() }
    self.backersTitleLabel |> dashboardStatTitleLabelStyle
    self.deadlineDateLabel |> dashboardFundingGraphXAxisLabelStyle
    self.fundingProgressTitleLabel |> dashboardFundingProgressTitleLabelStyle
    self.graphAxisSeparatorView |> dashboardFundingGraphAxisSeparatorViewStyle
    self.graphBackgroundView
      |> containerViewBackgroundStyle
      |> UIView.lens.accessibilityElementsHidden .~ true
    self.graphView |> UIView.lens.layoutMargins .~ .init(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
    self.graphXAxisStackView |> dashboardFundingGraphXAxisStackViewStyle
    self.graphYAxisBottomLabel |> dashboardFundingGraphYAxisLabelStyle
    self.graphYAxisMiddleLabel |> dashboardFundingGraphYAxisLabelStyle
    self.graphYAxisTopLabel |> dashboardFundingGraphYAxisLabelStyle
    self.launchDateLabel |> dashboardFundingGraphXAxisLabelStyle
    self.pledgedSubtitleLabel |> dashboardStatSubtitleLabelStyle
    self.pledgedTitleLabel
      |> dashboardStatTitleLabelStyle
      |> UILabel.lens.textColor .~ .ksr_text_green_700
    self.separatorViews ||> separatorStyle
    self.statsStackView |> dashboardFundingStatsStackView
    self.timeRemainingSubtitleLabel |> dashboardStatSubtitleLabelStyle
    self.timeRemainingTitleLabel |> dashboardStatTitleLabelStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersText
    self.deadlineDateLabel.rac.text = self.viewModel.outputs.deadlineDateText
    self.graphYAxisBottomLabel.rac.text = self.viewModel.outputs.graphYAxisBottomLabelText
    self.graphYAxisMiddleLabel.rac.text = self.viewModel.outputs.graphYAxisMiddleLabelText
    self.graphYAxisTopLabel.rac.text = self.viewModel.outputs.graphYAxisTopLabelText
    self.launchDateLabel.rac.text = self.viewModel.outputs.launchDateText
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledgedText
    self.pledgedSubtitleLabel.rac.text = self.viewModel.outputs.goalText
    self.timeRemainingSubtitleLabel.rac.text = self.viewModel.outputs.timeRemainingSubtitleText
    self.timeRemainingTitleLabel.rac.text = self.viewModel.outputs.timeRemainingTitleText

    self.viewModel.outputs.graphData
      .observeForUI()
      .observeNext { [weak self] data in
        self?.graphView.project = data.project
        self?.graphView.stats = data.stats
        self?.graphView.yAxisTickSize = data.yAxisTickSize
    }
  }

  internal func configureWith(value value: ([ProjectStatsEnvelope.FundingDateStats], Project)) {
    self.viewModel.inputs.configureWith(fundingDateStats: value.0, project: value.1)
  }
}
