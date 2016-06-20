import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardContextCell: UITableViewCell, ValueCell {
  private let viewModel: DashboardContextCellViewModelType = DashboardContextCellViewModel()

  @IBOutlet private weak var backersSubtitleLabel: UILabel!
  @IBOutlet private weak var backersTitleLabel: UILabel!
  @IBOutlet private weak var deadlineSubtitleLabel: UILabel!
  @IBOutlet private weak var deadlineTitleLabel: UILabel!
  @IBOutlet private weak var pledgedSubtitleLabel: UILabel!
  @IBOutlet private weak var pledgedTitleLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private var statColumnStackView: [UIStackView]!
  @IBOutlet private weak var statsColumnsStackView: UIStackView!

  internal override func bindStyles() {
    self |> dashboardContextCellStyle

    self.backersTitleLabel |> dashboardStatTitleLabelStyle
    self.deadlineTitleLabel |> dashboardStatTitleLabelStyle
    self.pledgedTitleLabel |> dashboardStatTitleLabelStyle

    self.backersSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text .~ Strings.dashboard_tout_backers()

    self.deadlineSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text .~ Strings.dashboard_tout_remaining()

    self.pledgedSubtitleLabel
      |> dashboardStatSubtitleLabelStyle
      |> UILabel.lens.text .~ Strings.dashboard_tout_pledged()

    self.statsColumnsStackView
      |> UIStackView.lens.distribution .~ .EqualSpacing
      |> UIStackView.lens.spacing .~ 24.0

    self.statColumnStackView.forEach {
      $0
        |> UIStackView.lens.distribution .~ .Fill
        |> UIStackView.lens.spacing .~ 2.0
        |> UIStackView.lens.alignment .~ .Leading
    }
  }

  internal override func bindViewModel() {
    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersCount
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadline
    self.pledgedTitleLabel.rac.text = self.viewModel.outputs.pledged

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }
  }

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }
}
