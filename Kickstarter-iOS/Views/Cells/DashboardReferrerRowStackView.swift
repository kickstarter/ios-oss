import Library
import KsApi
import Prelude
import UIKit

internal final class DashboardReferrerRowStackView: UIStackView {
  private let viewModel: DashboardReferrerRowStackViewViewModelType = DashboardReferrerRowStackViewViewModel()

  private let backersLabel: UILabel = UILabel()
  private let percentLabel: UILabel = UILabel()
  private let pledgedLabel: UILabel = UILabel()
  private let sourceLabel: UILabel = UILabel()

  internal init(frame: CGRect,
                country: Project.Country,
                referrer: ProjectStatsEnvelope.ReferrerStats) {

    super.init(frame: frame)

    self |> UIStackView.lens.axis .~ .Horizontal
      <> UIStackView.lens.alignment .~ .Fill
      <> UIStackView.lens.distribution .~ .FillEqually
      <> UIStackView.lens.spacing .~ 15
      <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.backersLabel |> dashboardReferrersRowLabelStyle
    self.percentLabel |> dashboardReferrersRowLabelStyle
    self.pledgedLabel |> dashboardReferrersRowLabelStyle
    self.sourceLabel |> dashboardReferrersRowLabelStyle

    self.addArrangedSubview(self.sourceLabel)
    self.addArrangedSubview(self.backersLabel)
    self.addArrangedSubview(self.pledgedLabel)
    self.addArrangedSubview(self.percentLabel)

    let textColor = self.viewModel.outputs.textColor

    self.backersLabel.rac.text = self.viewModel.outputs.backersText
    self.backersLabel.rac.textColor = textColor

    self.percentLabel.rac.text = self.viewModel.outputs.percentText
    self.percentLabel.rac.textColor = textColor

    self.pledgedLabel.rac.text = self.viewModel.outputs.pledgedText
    self.pledgedLabel.rac.textColor = textColor

    self.sourceLabel.rac.text = self.viewModel.outputs.sourceText
    self.sourceLabel.rac.textColor = textColor

    self.viewModel.inputs.configureWith(country: country, referrer: referrer)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:\(aDecoder)) has not been implemented")
  }
}
