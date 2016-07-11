import Library
import KsApi
import Prelude
import UIKit

internal final class DashboardReferrerRowStackView: UIStackView {
  private let viewModel: DashboardReferrerRowStackViewViewModelType = DashboardReferrerRowStackViewViewModel()

  private let backersLabel: UILabel = UILabel()
  private let pledgedLabel: UILabel = UILabel()
  private let sourceLabel: UILabel = UILabel()

  internal init(frame: CGRect,
                country: Project.Country,
                referrer: ProjectStatsEnvelope.ReferrerStats) {

    super.init(frame: frame)

    self |> dashboardStatsRowStackViewStyle

    self.backersLabel |> dashboardColumnTextLabelStyle
    self.pledgedLabel |> dashboardColumnTextLabelStyle
    self.sourceLabel |> dashboardReferrersSourceLabelStyle

    self.addArrangedSubview(self.sourceLabel)
    self.addArrangedSubview(self.pledgedLabel)
    self.addArrangedSubview(self.backersLabel)

    self.backersLabel.rac.text = self.viewModel.outputs.backersText
    self.pledgedLabel.rac.text = self.viewModel.outputs.pledgedText

    self.sourceLabel.rac.text = self.viewModel.outputs.sourceText
    self.sourceLabel.rac.textColor = self.viewModel.outputs.textColor

    self.viewModel.inputs.configureWith(country: country, referrer: referrer)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:\(aDecoder)) has not been implemented")
  }
}
