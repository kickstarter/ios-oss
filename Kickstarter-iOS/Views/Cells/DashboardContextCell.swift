import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DashboardContextCell: UITableViewCell, ValueCell {
  private let viewModel: DashboardContextCellViewModelType = DashboardContextCellViewModel()

  @IBOutlet private weak var backersCountLabel: UILabel!
  @IBOutlet private weak var backersLabel: UILabel!
  @IBOutlet private weak var deadlineLabel: UILabel!
  @IBOutlet private weak var pledgedAmountLabel: UILabel!
  @IBOutlet private weak var pledgedLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var remainingLabel: UILabel!

  internal override func bindStyles() {
    self.backersLabel |> dashboardBackersLabelStyle
    self.pledgedLabel |> dashboardPledgedLabelStyle
    self.remainingLabel |> dashboardRemainingLabelStyle
  }

  internal override func bindViewModel() {
    self.backersCountLabel.rac.text = self.viewModel.outputs.backersCount
    self.deadlineLabel.rac.text = self.viewModel.outputs.deadline
    self.pledgedAmountLabel.rac.text = self.viewModel.outputs.pledged

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
