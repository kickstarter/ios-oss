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
  @IBOutlet private weak var backersColumnTitleButton: UIButton!
  @IBOutlet private weak var externalPercentLabel: UILabel!
  @IBOutlet private weak var externalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet private weak var externalPledgedAmountTitleLabel: UILabel!
  @IBOutlet private weak var internalPercentLabel: UILabel!
  @IBOutlet private weak var internalPledgedAmountSubtitleLabel: UILabel!
  @IBOutlet private weak var internalPledgedAmountTitleLabel: UILabel!
  @IBOutlet private weak var percentColumnTitleButton: UIButton!
  @IBOutlet private weak var pledgedColumnTitleButton: UIButton!
  @IBOutlet private weak var referrersTitleLabel: UILabel!
  @IBOutlet private weak var referrersStackView: UIStackView!
  @IBOutlet private weak var showMoreReferrersButton: UIButton!
  @IBOutlet private weak var sourceColumnTitleButton: UIButton!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.backersColumnTitleButton.addTarget(
      self,
      action: #selector(backersButtonTapped),
      forControlEvents: .TouchUpInside
    )

    self.percentColumnTitleButton.addTarget(
      self,
      action: #selector(percentButtonTapped),
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

    self.averagePledgeAmountSubtitleLabel |> dashboardReferrersPledgeAmountSubtitleLabelStyle

    self.averagePledgeAmountTitleLabel
      |> dashboardReferrersPledgeAmountTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_average_pledge_amount() }

    self.backersColumnTitleButton
      |> dashboardReferrersColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_backers() }

    self.externalPercentLabel |> dashboardReferrersPledgePercentLabelStyle

    self.externalPledgedAmountSubtitleLabel |> dashboardReferrersPledgeAmountSubtitleLabelStyle

    self.externalPledgedAmountTitleLabel
      |> dashboardReferrersPledgeAmountTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_external() }

    self.internalPercentLabel
      |> dashboardReferrersPledgePercentLabelStyle
      |> UILabel.lens.textColor .~ .ksr_green

    self.internalPledgedAmountSubtitleLabel
      |> dashboardReferrersPledgeAmountSubtitleLabelStyle
      |> UILabel.lens.textColor .~ .ksr_green

    self.internalPledgedAmountTitleLabel
      |> dashboardReferrersPledgeAmountTitleLabelStyle
      |> UILabel.lens.textColor .~ .ksr_green
      |> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_pledged_via_kickstarter() }

    self.percentColumnTitleButton
      |> dashboardReferrersColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_percent() }

    self.pledgedColumnTitleButton
      |> dashboardReferrersColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_pledged() }

    self.referrersTitleLabel |> dashboardReferrersTitleLabelStyle

    self.showMoreReferrersButton |> dashboardReferrersShowMoreButtonStyle

    self.sourceColumnTitleButton
      |> dashboardReferrersColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_referrers_source() }
  }

  internal override func bindViewModel() {
    self.averagePledgeAmountSubtitleLabel.rac.text = self.viewModel.outputs.averagePledgeText
    self.externalPercentLabel.rac.text = self.viewModel.outputs.externalPercentText
    self.externalPledgedAmountSubtitleLabel.rac.text = self.viewModel.outputs.externalPledgedText
    self.internalPercentLabel.rac.text = self.viewModel.outputs.internalPercentText
    self.internalPledgedAmountSubtitleLabel.rac.text = self.viewModel.outputs.internalPledgedText

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
  }

  internal func addReferrerRows(withData data: ReferrersRowData) {
    referrersStackView.subviews
      .filter { $0 is DashboardReferrerRowStackView }
      .forEach { $0.removeFromSuperview() }

    data.referrers
      .map { DashboardReferrerRowStackView(
        frame: self.frame,
        country: data.country,
        referrer: $0)
      }
      .forEach(self.referrersStackView.addArrangedSubview)
  }

  internal func configureWith(value value: (ProjectStatsEnvelope.Cumulative,
                                            Project,
                                            [ProjectStatsEnvelope.ReferrerStats])) {
    self.viewModel.inputs.configureWith(cumulative: value.0, project: value.1, referrers: value.2)
  }

  @objc private func backersButtonTapped() {
    self.viewModel.inputs.backersButtonTapped()
  }

  @objc private func percentButtonTapped() {
    self.viewModel.inputs.percentButtonTapped()
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
