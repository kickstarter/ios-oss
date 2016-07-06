import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardRewardsCellDelegate: class {
  /// Call when stack view rows are added to expand the cell size.
  func dashboardRewardsCellDidAddRewardRows(cell: DashboardRewardsCell?)
}

internal final class DashboardRewardsCell: UITableViewCell, ValueCell {
  private let viewModel: DashboardRewardsCellViewModelType = DashboardRewardsCellViewModel()

  @IBOutlet private weak var mainStackView: UIStackView!
  @IBOutlet private weak var rewardsTitle: UILabel!
  @IBOutlet private weak var topRewardsButton: UIButton!
  @IBOutlet private weak var backersButton: UIButton!
  @IBOutlet private weak var percentButton: UIButton!
  @IBOutlet private weak var pledgedButton: UIButton!
  @IBOutlet private weak var seeAllTiersButton: UIButton!

  internal weak var delegate: DashboardRewardsCellDelegate?

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.topRewardsButton.addTarget(self,
                                    action: #selector(topRewardsButtonTapped),
                                    forControlEvents: .TouchUpInside)
    self.backersButton.addTarget(self,
                                 action: #selector(backersButtonTapped),
                                 forControlEvents: .TouchUpInside)
    self.percentButton.addTarget(self,
                                 action: #selector(percentButtonTapped),
                                 forControlEvents: .TouchUpInside)
    self.pledgedButton.addTarget(self,
                                 action: #selector(pledgedButtonTapped),
                                 forControlEvents: .TouchUpInside)

    self.seeAllTiersButton.addTarget(self,
                                 action: #selector(seeAllTiersButtonTapped),
                                 forControlEvents: .TouchUpInside)
  }

  internal override func bindStyles() {
    self |> baseTableViewCellStyle()

    self.rewardsTitle
      |> dashboardRewardTitleLabelStyle
    self.topRewardsButton
      |> dashboardRewardRowTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_top_rewards() }
    self.backersButton
      |> dashboardRewardRowTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_backers() }
    self.percentButton
      |> dashboardRewardRowTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_percent() }
    self.pledgedButton
      |> dashboardRewardRowTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_pledged() }
    self.seeAllTiersButton
      |> dashboardRewardSeeAllButtonStyle
  }

  internal override func bindViewModel() {
    self.seeAllTiersButton.rac.hidden = self.viewModel.outputs.hideSeeAllTiersButton

    self.viewModel.outputs.notifyDelegateAddedRewardRows
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.delegate?.dashboardRewardsCellDidAddRewardRows(self)
    }

    self.viewModel.outputs.rewardsRowData
      .observeForUI()
      .observeNext { [weak self] data in
        self?.addRewardRows(withData: data)
    }
  }

  internal func addRewardRows(withData data: RewardsRowData) {
    mainStackView.subviews
      .filter { $0 is DashboardRewardRowStackView }
      .forEach { $0.removeFromSuperview() }

    data.rewardsStats
      .map { DashboardRewardRowStackView(
        frame: self.frame,
        country: data.country,
        reward: $0,
        totalPledged: data.totalPledged)
      }
      .forEach(self.mainStackView.addArrangedSubview)
  }

  internal func configureWith(value value: (rewardStats: [ProjectStatsEnvelope.RewardStats],
                                            project: Project)) {
    self.viewModel.inputs.configureWith(rewardStats: value.0, project: value.1)
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

  @objc private func topRewardsButtonTapped() {
    self.viewModel.inputs.topRewardsButtonTapped()
  }

  @objc private func seeAllTiersButtonTapped() {
    self.viewModel.inputs.seeAllTiersButtonTapped()
  }
}
