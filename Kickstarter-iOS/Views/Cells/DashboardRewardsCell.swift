import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardRewardsCellDelegate: class {
  /// Call when stack view rows are added to expand the cell size.
  func dashboardRewardsCellDidAddRewardRows(_ cell: DashboardRewardsCell?)
}

internal final class DashboardRewardsCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: DashboardRewardsCellViewModelType = DashboardRewardsCellViewModel()

  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var mainStackView: UIStackView!
  @IBOutlet fileprivate weak var rewardsTitle: UILabel!
  @IBOutlet fileprivate weak var topRewardsButton: UIButton!
  @IBOutlet fileprivate weak var backersButton: UIButton!
  @IBOutlet fileprivate weak var pledgedButton: UIButton!
  @IBOutlet fileprivate weak var seeAllTiersButton: UIButton!

  internal weak var delegate: DashboardRewardsCellDelegate?

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.topRewardsButton.addTarget(self,
                                    action: #selector(topRewardsButtonTapped),
                                    for: .touchUpInside)

    self.backersButton.addTarget(self,
                                 action: #selector(backersButtonTapped),
                                 for: .touchUpInside)

    self.pledgedButton.addTarget(self,
                                 action: #selector(pledgedButtonTapped),
                                 for: .touchUpInside)

    self.seeAllTiersButton.addTarget(self,
                                 action: #selector(seeAllTiersButtonTapped),
                                 for: .touchUpInside)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.containerView
      |> UIView.lens.backgroundColor .~ .white
      |> dashboardCardStyle

    _ = self.rewardsTitle
      |> dashboardRewardTitleLabelStyle

    _ = self.topRewardsButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_graphs_rewards_top_rewards() }

    _ = self.backersButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_graphs_rewards_backers() }

    _ = self.pledgedButton
      |> dashboardColumnTitleButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_graphs_rewards_pledged() }

    _ = self.seeAllTiersButton
      |> dashboardGreenTextBorderButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.dashboard_graphs_rewards_view_more_reward_stats()
    }
  }

  internal override func bindViewModel() {
    self.seeAllTiersButton.rac.hidden = self.viewModel.outputs.hideSeeAllTiersButton

    self.viewModel.outputs.notifyDelegateAddedRewardRows
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.delegate?.dashboardRewardsCellDidAddRewardRows(self)
    }

    self.viewModel.outputs.rewardsRowData
      .observeForUI()
      .observeValues { [weak self] data in
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

        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

        self.mainStackView.addArrangedSubview(divider)
      }
    }
  }

  internal func configureWith(value: (rewardStats: [ProjectStatsEnvelope.RewardStats],
                              project: Project)) {
    self.viewModel.inputs.configureWith(rewardStats: value.0, project: value.1)
  }

  @objc fileprivate func backersButtonTapped() {
    self.viewModel.inputs.backersButtonTapped()
  }

  @objc fileprivate func pledgedButtonTapped() {
    self.viewModel.inputs.pledgedButtonTapped()
  }

  @objc fileprivate func topRewardsButtonTapped() {
    self.viewModel.inputs.topRewardsButtonTapped()
  }

  @objc fileprivate func seeAllTiersButtonTapped() {
    self.viewModel.inputs.seeAllTiersButtonTapped()
  }
}
