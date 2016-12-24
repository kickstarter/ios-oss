import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardReferrersCellDelegate: class {
  /// Call when referrer stack view rows are added to expand the cell size.
  func dashboardReferrersCellDidAddReferrerRows(_ cell: DashboardReferrersCell?)
}

internal final class DashboardReferrersCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardReferrersCellDelegate?
  fileprivate let viewModel: DashboardReferrersCellViewModelType = DashboardReferrersCellViewModel()

  @IBOutlet fileprivate weak var averagePledgeAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var averagePledgeAmountTitleLabel: UILabel!
  @IBOutlet fileprivate weak var averageStackView: UIStackView!
  @IBOutlet fileprivate weak var backersColumnTitleButton: UIButton!
  @IBOutlet fileprivate weak var cumulativeStackView: UIStackView!
  @IBOutlet fileprivate weak var customPercentLabel: UILabel!
  @IBOutlet fileprivate weak var customPercentIndicatorLabel: UILabel!
  @IBOutlet fileprivate weak var customPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var customPledgedAmountTitleLabel: UILabel!
  @IBOutlet fileprivate weak var customStackView: UIStackView!
  @IBOutlet fileprivate weak var externalPercentLabel: UILabel!
  @IBOutlet fileprivate weak var externalPercentIndicatorLabel: UILabel!
  @IBOutlet fileprivate weak var externalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var externalPledgedAmountTitleLabel: UILabel!
  @IBOutlet fileprivate weak var internalPercentLabel: UILabel!
  @IBOutlet fileprivate weak var internalPercentIndicatorLabel: UILabel!
  @IBOutlet fileprivate weak var internalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var internalPledgedAmountTitleLabel: UILabel!
  @IBOutlet fileprivate weak var pledgedColumnTitleButton: UIButton!
  @IBOutlet fileprivate weak var referralChartView: ReferralChartView!
  @IBOutlet fileprivate weak var referrersTitleLabel: UILabel!
  @IBOutlet fileprivate weak var referrersStackView: UIStackView!
  @IBOutlet fileprivate weak var showMoreReferrersButton: UIButton!
  @IBOutlet fileprivate weak var sourceColumnTitleButton: UIButton!
  @IBOutlet fileprivate weak var chartCardView: UIView!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.backersColumnTitleButton.addTarget(
      self,
      action: #selector(backersButtonTapped),
      for: .touchUpInside
    )

    self.pledgedColumnTitleButton.addTarget(
      self,
      action: #selector(pledgedButtonTapped),
      for: .touchUpInside
    )

    self.showMoreReferrersButton.addTarget(
      self,
      action: #selector(showMoreReferrersTapped),
      for: .touchUpInside
    )

    self.sourceColumnTitleButton.addTarget(
      self,
      action: #selector(sourceButtonTapped),
      for: .touchUpInside
    )
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    self |> baseTableViewCellStyle()

    self.averagePledgeAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_average_pledge_amount() }

    self.averagePledgeAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    self.backersColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_graphs_referrers_backers() }

    self.customPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle

    self.customPercentIndicatorLabel
      |> UILabel.lens.textColor .~ .ksr_violet_500

    self.customPledgedAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    self.customPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_custom() }

    self.externalPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle

    self.externalPercentIndicatorLabel
      |> UILabel.lens.textColor .~ .ksr_orange_400

    self.externalPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_external() }

    self.externalPledgedAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    self.internalPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle

    self.internalPercentIndicatorLabel
      |> UILabel.lens.textColor .~ .ksr_green_700

    self.internalPledgedAmountSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_kickstarter() }

    self.internalPledgedAmountTitleLabel
      |> dashboardStatTitleLabelStyle

    self.pledgedColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_graphs_referrers_pledged() }

    self.referrersTitleLabel
      |> dashboardReferrersTitleLabelStyle

    self.referralChartView
      |> UIView.lens.backgroundColor .~ .clear

    self.showMoreReferrersButton
      |> dashboardReferrersShowMoreButtonStyle

    self.sourceColumnTitleButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.dashboard_graphs_referrers_source() }

    self.chartCardView
      |> dashboardChartCardViewStyle

    self.cumulativeStackView
      |> dashboardReferrersCumulativeStackViewStyle

    self.averageStackView
      |> dashboardReferrersCumulativeStackViewStyle

    self.separatorViews.forEach { $0 |> separatorStyle }
  }
  // swiftlint:enable function_body_length

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

        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

        self.referrersStackView.addArrangedSubview(divider)
      }
    }
  }

  internal func configureWith(value: (ProjectStatsEnvelope.CumulativeStats,
                                            Project,
                                            [ProjectStatsEnvelope.ReferrerStats])) {
    self.viewModel.inputs.configureWith(cumulative: value.0, project: value.1, referrers: value.2)
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
