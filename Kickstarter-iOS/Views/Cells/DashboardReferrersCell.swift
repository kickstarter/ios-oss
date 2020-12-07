import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardReferrersCellDelegate: AnyObject {
  /// Call when referrer stack view rows are added to expand the cell size.
  func dashboardReferrersCellDidAddReferrerRows(_ cell: DashboardReferrersCell?)
}

internal final class DashboardReferrersCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardReferrersCellDelegate?
  fileprivate let viewModel: DashboardReferrersCellViewModelType = DashboardReferrersCellViewModel()

  @IBOutlet fileprivate var averagePledgeAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate var averagePledgeAmountTitleLabel: UILabel!
  @IBOutlet fileprivate var averageStackView: UIStackView!
  @IBOutlet fileprivate var backersColumnTitleButton: UIButton!
  @IBOutlet fileprivate var cumulativeStackView: UIStackView!
  @IBOutlet fileprivate var customPercentLabel: UILabel!
  @IBOutlet fileprivate var customPercentIndicatorLabel: UILabel!
  @IBOutlet fileprivate var customPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate var customPledgedAmountTitleLabel: UILabel!
  @IBOutlet fileprivate var externalPercentLabel: UILabel!
  @IBOutlet fileprivate var externalPercentIndicatorLabel: UILabel!
  @IBOutlet fileprivate var externalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate var externalPledgedAmountTitleLabel: UILabel!
  @IBOutlet fileprivate var internalPercentLabel: UILabel!
  @IBOutlet fileprivate var internalPercentIndicatorLabel: UILabel!
  @IBOutlet fileprivate var internalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate var internalPledgedAmountTitleLabel: UILabel!
  @IBOutlet fileprivate var pledgedColumnTitleButton: UIButton!
  @IBOutlet fileprivate var referralChartView: ReferralChartView!
  @IBOutlet fileprivate var referrersTitleLabel: UILabel!
  @IBOutlet fileprivate var referrersStackView: UIStackView!
  @IBOutlet fileprivate var showMoreReferrersButton: UIButton!
  @IBOutlet fileprivate var sourceColumnTitleButton: UIButton!
  @IBOutlet fileprivate var chartCardView: UIView!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.backersColumnTitleButton.addTarget(
      self,
      action: #selector(self.backersButtonTapped),
      for: .touchUpInside
    )

    self.pledgedColumnTitleButton.addTarget(
      self,
      action: #selector(self.pledgedButtonTapped),
      for: .touchUpInside
    )

    self.showMoreReferrersButton.addTarget(
      self,
      action: #selector(self.showMoreReferrersTapped),
      for: .touchUpInside
    )

    self.sourceColumnTitleButton.addTarget(
      self,
      action: #selector(self.sourceButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.awakeFromNib()
  }

  internal override func bindStyles() {
    _ = self |> baseTableViewCellStyle()

    _ = self.averagePledgeAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_average_pledge_amount() }

    _ = self.averagePledgeAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    _ = self.backersColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_graphs_referrers_backers() }

    _ = self.customPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle

    _ = self.customPercentIndicatorLabel
      |> UILabel.lens.textColor .~ .ksr_trust_500

    _ = self.customPledgedAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    _ = self.customPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_custom() }

    _ = self.externalPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle

    _ = self.externalPercentIndicatorLabel
      |> UILabel.lens.textColor .~ .ksr_celebrate_500

    _ = self.externalPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_external() }

    _ = self.externalPledgedAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    _ = self.internalPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle

    _ = self.internalPercentIndicatorLabel
      |> UILabel.lens.textColor .~ .ksr_create_700

    _ = self.internalPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_kickstarter() }

    _ = self.internalPledgedAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    _ = self.pledgedColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_graphs_referrers_pledged() }

    _ = self.referrersTitleLabel
      |> dashboardReferrersTitleLabelStyle

    _ = self.referralChartView
      |> UIView.lens.backgroundColor .~ .clear

    _ = self.showMoreReferrersButton
      |> dashboardReferrersShowMoreButtonStyle

    _ = self.sourceColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_graphs_referrers_source() }

    _ = self.chartCardView
      |> dashboardChartCardViewStyle

    _ = self.cumulativeStackView
      |> dashboardReferrersCumulativeStackViewStyle

    _ = self.averageStackView
      |> dashboardReferrersCumulativeStackViewStyle

    self.separatorViews.forEach { _ = $0 |> separatorStyle }
  }

  internal override func bindViewModel() {
    self.averagePledgeAmountTitleLabel.rac.text = self.viewModel.outputs.averagePledgeText
    self.customPercentLabel.rac.text = self.viewModel.outputs.customPercentText
    self.customPledgedAmountTitleLabel.rac.text = self.viewModel.outputs.customPledgedText
    self.externalPercentLabel.rac.text = self.viewModel.outputs.externalPercentText
    self.externalPledgedAmountTitleLabel.rac.text = self.viewModel.outputs.externalPledgedText
    self.internalPercentLabel.rac.text = self.viewModel.outputs.internalPercentText
    self.internalPledgedAmountTitleLabel.rac.text = self.viewModel.outputs.internalPledgedText

    self.viewModel.outputs.notifyDelegateAddedReferrerRows
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.delegate?.dashboardReferrersCellDidAddReferrerRows(self)
      }

    self.viewModel.outputs.referrersRowData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.addReferrerRows(withData: data)
      }

    self.showMoreReferrersButton.rac.hidden = self.viewModel.outputs.showMoreReferrersButtonHidden

    self.viewModel.outputs.externalPercentage
      .observeForUI()
      .observeValues { [weak self] in self?.referralChartView.externalPercentage = CGFloat($0) }

    self.viewModel.outputs.internalPercentage
      .observeForUI()
      .observeValues { [weak self] in self?.referralChartView.internalPercentage = CGFloat($0) }
  }

  internal func addReferrerRows(withData data: ReferrersRowData) {
    self.referrersStackView.subviews.forEach { $0.removeFromSuperview() }

    let referrers = data.referrers
      .map { DashboardReferrerRowStackView(frame: self.frame, country: data.country, referrer: $0) }

    let refsCount = referrers.count
    (0..<refsCount).forEach {
      self.referrersStackView.addArrangedSubview(referrers[$0])

      if $0 < refsCount - 1 {
        let divider = UIView() |> UIView.lens.backgroundColor .~ .ksr_support_300

        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

        self.referrersStackView.addArrangedSubview(divider)
      }
    }
  }

  internal func configureWith(value: (
    ProjectStatsEnvelope.CumulativeStats, Project,
    ProjectStatsEnvelope.ReferralAggregateStats, [ProjectStatsEnvelope.ReferrerStats]
  )) {
    self.viewModel.inputs.configureWith(
      cumulative: value.0, project: value.1,
      referralAggregates: value.2, referrers: value.3
    )
  }

  @objc fileprivate func backersButtonTapped() {
    self.viewModel.inputs.backersButtonTapped()
  }

  @objc fileprivate func pledgedButtonTapped() {
    self.viewModel.inputs.pledgedButtonTapped()
  }

  @objc fileprivate func showMoreReferrersTapped() {
    self.viewModel.inputs.showMoreReferrersTapped()
  }

  @objc fileprivate func sourceButtonTapped() {
    self.viewModel.inputs.sourceButtonTapped()
  }
}
