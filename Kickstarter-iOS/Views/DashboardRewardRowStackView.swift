import Library
import KsApi
import UIKit
import Prelude

internal final class DashboardRewardRowStackView: UIStackView {
  private let vm: DashboardRewardRowStackViewViewModelType = DashboardRewardRowStackViewViewModel()

  private let rewardsLabel: UILabel = UILabel()
  private let backersLabel: UILabel = UILabel()
  private let percentLabel: UILabel = UILabel()
  private let pledgedLabel: UILabel = UILabel()

  internal init(frame: CGRect,
                country: Project.Country,
                reward: ProjectStatsEnvelope.RewardStats,
                totalPledged: Int) {

    super.init(frame: frame)

    self |> UIStackView.lens.axis .~ .Horizontal
      <> UIStackView.lens.alignment .~ .Fill
      <> UIStackView.lens.distribution .~ .FillEqually
      <> UIStackView.lens.spacing .~ 15
      <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.rewardsLabel |> dashboardRewardRowLabelStyle
    self.backersLabel |> dashboardRewardRowLabelStyle
    self.percentLabel |> dashboardRewardRowLabelStyle
    self.pledgedLabel |> dashboardRewardRowLabelStyle

    self.addArrangedSubview(self.rewardsLabel)
    self.addArrangedSubview(self.backersLabel)
    self.addArrangedSubview(self.percentLabel)
    self.addArrangedSubview(self.pledgedLabel)

    self.rewardsLabel.rac.text = self.vm.outputs.topRewardText
    self.percentLabel.rac.text = self.vm.outputs.percentText
    self.pledgedLabel.rac.text = self.vm.outputs.pledgedText
    self.backersLabel.rac.text = self.vm.outputs.backersText

    self.vm.inputs.configureWith(country: country, reward: reward, totalPledged: totalPledged)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
