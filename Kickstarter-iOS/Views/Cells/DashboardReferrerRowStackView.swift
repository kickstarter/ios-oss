import Library
import KsApi
import Prelude
import UIKit

internal final class DashboardReferrerRowStackView: UIStackView {
  fileprivate let viewModel: DashboardReferrerRowStackViewViewModelType
    = DashboardReferrerRowStackViewViewModel()

  fileprivate let backersLabel: UILabel = UILabel()
  fileprivate let pledgedLabel: UILabel = UILabel()
  fileprivate let sourceLabel: UILabel = UILabel()

  internal init(frame: CGRect,
                country: Project.Country,
                referrer: ProjectStatsEnvelope.ReferrerStats) {

    super.init(frame: frame)

    _ = self |> dashboardStatsRowStackViewStyle

    _ = self.backersLabel |> dashboardColumnTextLabelStyle
    _ = self.pledgedLabel |> dashboardColumnTextLabelStyle
    _ = self.sourceLabel |> dashboardReferrersSourceLabelStyle

    self.addArrangedSubview(self.sourceLabel)
    self.addArrangedSubview(self.pledgedLabel)
    self.addArrangedSubview(self.backersLabel)

    self.backersLabel.rac.text = self.viewModel.outputs.backersText
    self.pledgedLabel.rac.text = self.viewModel.outputs.pledgedText

    self.sourceLabel.rac.text = self.viewModel.outputs.sourceText
    self.sourceLabel.rac.textColor = self.viewModel.outputs.textColor

    self.viewModel.inputs.configureWith(country: country, referrer: referrer)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:\(aDecoder)) has not been implemented")
  }
}
