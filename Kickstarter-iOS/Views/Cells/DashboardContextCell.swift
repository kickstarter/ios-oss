import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardContextCellDelegate: class {
  /// Call with project value when navigating to project screen.
  func goToProject(cell: DashboardContextCell?, project: Project, refTag: RefTag)
}

internal final class DashboardContextCell: UITableViewCell, ValueCell {
  internal weak var delegate: DashboardContextCellDelegate?
  private let viewModel: DashboardContextCellViewModelType = DashboardContextCellViewModel()

  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var viewProjectButton: UIButton!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.viewProjectButton.addTarget(
      self,
      action: #selector(viewProjectTapped),
      forControlEvents: .TouchUpInside
    )
  }

  internal override func bindStyles() {
    self |> dashboardContextCellStyle

    self.containerView |> containerViewBackgroundStyle

    self.projectNameLabel |> dashboardStatTitleLabelStyle

    self.separatorView |> separatorStyle

    self.viewProjectButton |> dashboardViewProjectButtonStyle
  }

  internal override func bindViewModel() {
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.delegate?.goToProject(self, project: project, refTag: refTag)
    }
  }

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  @objc private func viewProjectTapped() {
    self.viewModel.inputs.viewProjectTapped()
  }
}
