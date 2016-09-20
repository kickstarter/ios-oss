import Library
import KsApi
import UIKit
import Prelude

internal final class DashboardRewardRowStackView: UIStackView {
  private let vm: DashboardRewardRowStackViewViewModelType = DashboardRewardRowStackViewViewModel()

  private let rewardsLabel: UILabel = UILabel()
  private let backersLabel: UILabel = UILabel()
  private let pledgedLabel: UILabel = UILabel()

  internal init(frame: CGRect,
                country: Project.Country,
                reward: ProjectStatsEnvelope.RewardStats,
                totalPledged: Int) {

    super.init(frame: frame)

    self |> dashboardStatsRowStackViewStyle

    self.rewardsLabel
      |> dashboardColumnTextLabelStyle
      |> UILabel.lens.font .~ UIFont.ksr_subhead().bolded

    self.pledgedLabel |> dashboardColumnTextLabelStyle
    self.backersLabel |> dashboardColumnTextLabelStyle

    self.addArrangedSubview(self.rewardsLabel)
    self.addArrangedSubview(self.pledgedLabel)
    self.addArrangedSubview(self.backersLabel)

    self.rewardsLabel.rac.text = self.vm.outputs.topRewardText
    self.pledgedLabel.rac.text = self.vm.outputs.pledgedText
    self.backersLabel.rac.text = self.vm.outputs.backersText

    self.vm.inputs.configureWith(country: country, reward: reward, totalPledged: totalPledged)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
