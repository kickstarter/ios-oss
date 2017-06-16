import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol DashboardProjectsDrawerViewControllerDelegate: class {
  /// Call when a project cell is tapped with the project.
  func dashboardProjectsDrawerCellDidTapProject(_ project: Project)

  /// Call when drawer view has completed animating out.
  func dashboardProjectsDrawerDidAnimateOut()

  /// Call when background view is tapped to close.
  func dashboardProjectsDrawerHideDrawer()
}

internal final class DashboardProjectsDrawerViewController: UITableViewController {

  internal weak var delegate: DashboardProjectsDrawerViewControllerDelegate?

  fileprivate let viewModel: DashboardProjectsDrawerViewModelType = DashboardProjectsDrawerViewModel()
  fileprivate let dataSource = DashboardProjectsDrawerDataSource()

  internal static func configuredWith(data: [ProjectsDrawerData])
    -> DashboardProjectsDrawerViewController {

      let vc = Storyboard.DashboardProjectsDrawer.instantiate(DashboardProjectsDrawerViewController.self)
      vc.viewModel.inputs.configureWith(data: data)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillDisappear(_ animated: Bool) {
    if let tapGesture = self.tableView.backgroundView?.gestureRecognizers?.first {
      self.tableView.backgroundView?.removeGestureRecognizer(tapGesture)
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projectsDrawerData
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.dataSource.load(data: data)
        self?.tableView.reloadData()
        self?.animateIn()
    }

    self.viewModel.outputs.notifyDelegateToCloseDrawer
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.delegate?.dashboardProjectsDrawerHideDrawer()
    }

    self.viewModel.outputs.notifyDelegateDidAnimateOut
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.delegate?.dashboardProjectsDrawerDidAnimateOut()
    }

    self.viewModel.outputs.notifyDelegateProjectCellTapped
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.delegate?.dashboardProjectsDrawerCellDidTapProject(project)
    }

    self.viewModel.outputs.focusScreenReaderOnFirstProject
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.accessibilityFocusOnFirstProject()
    }
  }

  override func bindStyles() {
    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 44.0)
      |> UITableViewController.lens.view.backgroundColor .~ .clear

    _ = self.tableView |> UITableView.lens.backgroundView .~ (
      UIView()
        |> UIView.lens.backgroundColor .~ .ksr_black_soft_100
        |> UIView.lens.alpha .~ 0.0
    )

    self.animateIn()
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let project = self.dataSource.projectAtIndexPath(indexPath) else { return }

    self.viewModel.inputs.projectCellTapped(project)
  }

  internal func animateOut() {
    self.tableView.backgroundView?.isUserInteractionEnabled = false

    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
      self.tableView.backgroundView?.alpha = 0.0
      self.tableView.contentOffset = CGPoint(x: 0.0, y: self.tableView.frame.size.height / 2)
      }, completion: { _ in
        self.viewModel.inputs.animateOutCompleted()
    })
  }

  fileprivate func animateIn() {
    self.tableView.contentOffset = CGPoint(x: 0.0, y: self.tableView.frame.size.height)

    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
      self.tableView.backgroundView?.alpha = 0.4
      }, completion: { _ in
        self.tableView.backgroundView?.addGestureRecognizer(
          UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped))
        )
    })

    UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               usingSpringWithDamping: 0.95,
                               initialSpringVelocity: 0.9,
                               options: .curveEaseOut,
                               animations: {
      self.tableView.contentOffset = CGPoint(x: 0.0, y: 0.0)
      }, completion: { _ in
        self.viewModel.inputs.animateInCompleted()
      }
    )
  }

  fileprivate func accessibilityFocusOnFirstProject() {
    let cell = self.tableView.visibleCells.filter { $0 is DashboardProjectsDrawerCell }.first
    if let cell = cell {
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, cell)
    }
  }

  override func accessibilityPerformEscape() -> Bool {
    self.viewModel.inputs.backgroundTapped()
    return true
  }

  @objc fileprivate func backgroundTapped() {
    self.viewModel.inputs.backgroundTapped()
  }
}
