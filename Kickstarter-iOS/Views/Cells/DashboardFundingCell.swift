import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardFundingCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: DashboardFundingCellViewModelType = DashboardFundingCellViewModel()

  @IBOutlet fileprivate var backersTitleLabel: UILabel!
  @IBOutlet fileprivate var backersSubtitleLabel: UILabel!
  @IBOutlet fileprivate var deadlineDateLabel: UILabel!
  @IBOutlet fileprivate var fundingProgressTitleLabel: UILabel!
  @IBOutlet fileprivate var graphAxisSeparatorView: UIView!
  @IBOutlet fileprivate var graphBackgroundView: UIView!
  @IBOutlet fileprivate var graphView: FundingGraphView!
  @IBOutlet fileprivate var graphViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var graphXAxisStackView: UIStackView!
  @IBOutlet fileprivate var graphYAxisBottomLabel: UILabel!
  @IBOutlet fileprivate var graphYAxisMiddleLabel: UILabel!
  @IBOutlet fileprivate var graphYAxisTopLabel: UILabel!
  @IBOutlet fileprivate var launchDateLabel: UILabel!
  @IBOutlet fileprivate var pledgedSubtitleLabel: UILabel!
  @IBOutlet fileprivate var pledgedTitleLabel: UILabel!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate var statsStackView: UIStackView!
  @IBOutlet fileprivate var timeRemainingSubtitleLabel: UILabel!
  @IBOutlet fileprivate var timeRemainingTitleLabel: UILabel!

  internal override func bindStyles() {
    super.bindStyles()

    self.accessibilityLabel = Strings.dashboard_graphs_funding_title_funding_progress()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.backersSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_tout_backers() }
    _ = self.backersTitleLabel |> dashboardStatTitleLabelStyle
    _ = self.deadlineDateLabel |> dashboardFundingGraphXAxisLabelStyle
    _ = self.fundingProgressTitleLabel |> dashboardFundingProgressTitleLabelStyle
    _ = self.graphAxisSeparatorView |> dashboardFundingGraphAxisSeparatorViewStyle
    _ = self.graphBackgroundView
      |> containerViewBackgroundStyle
      |> UIView.lens.accessibilityElementsHidden .~ true
    _ = self.graphView |> UIView.lens.layoutMargins .~ .init(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
    _ = self.graphXAxisStackView |> dashboardFundingGraphXAxisStackViewStyle
    _ = self.graphYAxisBottomLabel |> dashboardFundingGraphYAxisLabelStyle
    _ = self.graphYAxisMiddleLabel |> dashboardFundingGraphYAxisLabelStyle
    _ = self.graphYAxisTopLabel |> dashboardFundingGraphYAxisLabelStyle
    _ = self.launchDateLabel |> dashboardFundingGraphXAxisLabelStyle
    _ = self.pledgedSubtitleLabel |> dashboardStatSubtitleLabelStyle
    _ = self.pledgedTitleLabel
      |> dashboardStatTitleLabelStyle
      |> UILabel.lens.textColor .~ .ksr_create_700

    _ = self.rootStackView
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, stack in
        stack.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(12))
          : .init(all: 0.0)
      }

    _ = self.separatorViews ||> separatorStyle
    _ = self.statsStackView |> dashboardFundingStatsStackView
    _ = self.timeRemainingSubtitleLabel |> dashboardStatSubtitleLabelStyle
    _ = self.timeRemainingTitleLabel |> dashboardStatTitleLabelStyle

    self.graphViewHeightConstraint.constant = self.traitCollection.isRegularRegular
      ? Styles.grid(40) : Styles.grid(30)
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
      .observeValues { [weak self] data in
        self?.graphView.project = data.project
        self?.graphView.stats = data.stats
        self?.graphView.yAxisTickSize = data.yAxisTickSize
      }
  }

  internal func configureWith(value: ([ProjectStatsEnvelope.FundingDateStats], Project)) {
    self.viewModel.inputs.configureWith(fundingDateStats: value.0, project: value.1)
  }
}
