import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardReferrersCellDelegate: class {
  /// Call when referrer stack view rows are added to expand the cell size.
  func dashboardReferrersCellDidAddReferrerRows(cell: DashboardReferrersCell?)
}

internal final class DashboardReferrersCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardReferrersCellDelegate?
  private let viewModel: DashboardReferrersCellViewModelType = DashboardReferrersCellViewModel()

  @IBOutlet private weak var averagePledgeAmountSubtitleLabel: UILabel!
  @IBOutlet private weak var averagePledgeAmountTitleLabel: UILabel!
  @IBOutlet private weak var averageStackView: UIStackView!
  @IBOutlet private weak var backersColumnTitleButton: UIButton!
  @IBOutlet private weak var cumulativeStackView: UIStackView!
  @IBOutlet private weak var customPercentLabel: UILabel!
  @IBOutlet private weak var customPercentIndicatorLabel: UILabel!
  @IBOutlet private weak var customPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet private weak var customPledgedAmountTitleLabel: UILabel!
  @IBOutlet private weak var customStackView: UIStackView!
  @IBOutlet private weak var externalPercentLabel: UILabel!
  @IBOutlet private weak var externalPercentIndicatorLabel: UILabel!
  @IBOutlet private weak var externalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet private weak var externalPledgedAmountTitleLabel: UILabel!
  @IBOutlet private weak var internalPercentLabel: UILabel!
  @IBOutlet private weak var internalPercentIndicatorLabel: UILabel!
  @IBOutlet private weak var internalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet private weak var internalPledgedAmountTitleLabel: UILabel!
  @IBOutlet private weak var pledgedColumnTitleButton: UIButton!
  @IBOutlet private weak var referralChartView: ReferralChartView!
  @IBOutlet private weak var referrersTitleLabel: UILabel!
  @IBOutlet private weak var referrersStackView: UIStackView!
  @IBOutlet private weak var showMoreReferrersButton: UIButton!
  @IBOutlet private weak var sourceColumnTitleButton: UIButton!
  @IBOutlet private weak var chartCardView: UIView!
  @IBOutlet var separatorViews: [UIView]!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.backersColumnTitleButton.addTarget(
      self,
      action: #selector(backersButtonTapped),
      forControlEvents: .TouchUpInside
    )

    self.pledgedColumnTitleButton.addTarget(
      self,
      action: #selector(pledgedButtonTapped),
      forControlEvents: .TouchUpInside
    )

    self.showMoreReferrersButton.addTarget(
      self,
      action: #selector(showMoreReferrersTapped),
      forControlEvents: .TouchUpInside
    )

    self.sourceColumnTitleButton.addTarget(
      self,
      action: #selector(sourceButtonTapped),
      forControlEvents: .TouchUpInside
    )
  }

  internal override func bindStyles() {
    self |> baseTableViewCellStyle()

    self.averagePledgeAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_average_pledge_amount() }

    self.averagePledgeAmountTitleLabel |> dashboardStatTitleLabelStyle

    self.backersColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_backers() }

    self.customPercentLabel |> dashboardReferrersPledgePercentLabelStyle

    self.customPercentIndicatorLabel |> UILabel.lens.textColor .~ .ksr_violet_850

    self.customPledgedAmountTitleLabel |> dashboardStatTitleLabelStyle

    self.customPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_custom() }

    self.externalPercentLabel |> dashboardReferrersPledgePercentLabelStyle

    self.externalPercentIndicatorLabel |> UILabel.lens.textColor .~ .ksr_orange_400

    self.externalPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_external() }

    self.externalPledgedAmountTitleLabel |> dashboardStatTitleLabelStyle

    self.internalPercentLabel |> dashboardReferrersPledgePercentLabelStyle

    self.internalPercentIndicatorLabel |> UILabel.lens.textColor .~ .ksr_green_700

    self.internalPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_kickstarter() }

    self.internalPledgedAmountTitleLabel |> dashboardStatTitleLabelStyle

    self.pledgedColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_pledged() }

    self.referrersTitleLabel |> dashboardReferrersTitleLabelStyle

    self.showMoreReferrersButton |> dashboardReferrersShowMoreButtonStyle

    self.sourceColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_source() }

    self.chartCardView |> dashboardChartCardViewStyle

    self.cumulativeStackView |> dashboardReferrersCumulativeStackViewStyle

    self.averageStackView |> dashboardReferrersCumulativeStackViewStyle

    self.separatorViews.forEach { $0 |> separatorStyle }
  }

  internal override func bindViewModel() {
    self.averagePledgeAmountTitleLabel.rac.text = self.viewModel.outputs.averagePledgeText
    self.customPercentLabel.rac.text = self.viewModel.outputs.customPercentText
    self.customPledgedAmountTitleLabel.rac.text = self.viewModel.outputs.customPledgedText
    self.customStackView.rac.hidden = self.viewModel.outputs.customStackViewHidden
    self.externalPercentLabel.rac.text = self.viewModel.outputs.externalPercentText
    self.externalPledgedAmountTitleLabel.rac.text = self.viewModel.outputs.externalPledgedText
    self.internalPercentLabel.rac.text = self.viewModel.outputs.internalPercentText
    self.internalPledgedAmountTitleLabel.rac.text = self.viewModel.outputs.internalPledgedText

    self.viewModel.outputs.notifyDelegateAddedReferrerRows
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.delegate?.dashboardReferrersCellDidAddReferrerRows(self)
    }

    self.viewModel.outputs.referrersRowData
      .observeForUI()
      .observeNext { [weak self] data in
        self?.addReferrerRows(withData: data)
    }

    self.showMoreReferrersButton.rac.hidden = self.viewModel.outputs.showMoreReferrersButtonHidden

    self.viewModel.outputs.externalPercentage
      .observeForUI()
      .observeNext { [weak self] in self?.referralChartView.externalPercentage = CGFloat($0) }

    self.viewModel.outputs.internalPercentage
      .observeForUI()
      .observeNext { [weak self] in self?.referralChartView.internalPercentage = CGFloat($0) }
  }

  internal func addReferrerRows(withData data: ReferrersRowData) {
    referrersStackView.subviews.forEach { $0.removeFromSuperview() }

    let referrers = data.referrers
      .map { DashboardReferrerRowStackView(
        frame: self.frame,
        country: data.country,
        referrer: $0)
      }

    let refsCount = referrers.count
    (0..<refsCount).forEach {
      self.referrersStackView.addArrangedSubview(referrers[$0])

      if $0 < refsCount - 1 {
        let divider = UIView() |> UIView.lens.backgroundColor .~ .ksr_navy_300

        divider.heightAnchor.constraintEqualToConstant(1.0).active = true

        self.referrersStackView.addArrangedSubview(divider)
      }
    }
  }

  internal func configureWith(value value: (ProjectStatsEnvelope.CumulativeStats,
                                            Project,
                                            [ProjectStatsEnvelope.ReferrerStats])) {
    self.viewModel.inputs.configureWith(cumulative: value.0, project: value.1, referrers: value.2)
  }

  @objc private func backersButtonTapped() {
    self.viewModel.inputs.backersButtonTapped()
  }

  @objc private func pledgedButtonTapped() {
    self.viewModel.inputs.pledgedButtonTapped()
  }

  @objc private func showMoreReferrersTapped() {
    self.viewModel.inputs.showMoreReferrersTapped()
  }

  @objc private func sourceButtonTapped() {
    self.viewModel.inputs.sourceButtonTapped()
  }
}
