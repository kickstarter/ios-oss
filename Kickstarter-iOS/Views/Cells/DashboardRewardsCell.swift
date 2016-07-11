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

  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var mainStackView: UIStackView!
  @IBOutlet private weak var rewardsTitle: UILabel!
  @IBOutlet private weak var topRewardsButton: UIButton!
  @IBOutlet private weak var backersButton: UIButton!
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

    self.pledgedButton.addTarget(self,
                                 action: #selector(pledgedButtonTapped),
                                 forControlEvents: .TouchUpInside)

    self.seeAllTiersButton.addTarget(self,
                                 action: #selector(seeAllTiersButtonTapped),
                                 forControlEvents: .TouchUpInside)
  }

  internal override func bindStyles() {
    self |> baseTableViewCellStyle()

    self.containerView |> UIView.lens.backgroundColor .~ .whiteColor()

    self.rewardsTitle |> dashboardRewardTitleLabelStyle

    self.topRewardsButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_top_rewards() }

    self.backersButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_backers() }

    self.pledgedButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_graphs_rewards_pledged() }

    self.seeAllTiersButton
      |> dashboardGreenTextBorderButtonStyle
      |> UIButton.lens.titleText(forState: .Normal) %~ { _ in
        Strings.dashboard_graphs_rewards_view_more_reward_stats()
    }
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
    mainStackView.subviews.forEach { $0.removeFromSuperview() }

    let stats = data.rewardsStats
      .map { DashboardRewardRowStackView(
        frame: self.frame,
        country: data.country,
        reward: $0,
        totalPledged: data.totalPledged)
      }

    let statsCount = stats.count
    (0..<statsCount).forEach {
      self.mainStackView.addArrangedSubview(stats[$0])

      if $0 < statsCount - 1 {
        let divider = UIView() |> UIView.lens.backgroundColor .~ .ksr_navy_300

        divider.heightAnchor.constraintEqualToConstant(1.0).active = true

        self.mainStackView.addArrangedSubview(divider)
      }
    }
  }

  internal func configureWith(value value: (rewardStats: [ProjectStatsEnvelope.RewardStats],
                                            project: Project)) {
    self.viewModel.inputs.configureWith(rewardStats: value.0, project: value.1)
  }

  @objc private func backersButtonTapped() {
    self.viewModel.inputs.backersButtonTapped()
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
