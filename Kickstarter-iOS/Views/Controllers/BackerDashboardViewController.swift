import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardViewController: UIViewController {

  @IBOutlet private weak var avatarView: CircleAvatarImageView!
  @IBOutlet private weak var backedSortLabel: UILabel!
  @IBOutlet private weak var backerNameLabel: UILabel!
  @IBOutlet private weak var backerNumberLabel: UILabel!
  @IBOutlet private weak var dividerView: UIView!
  @IBOutlet private weak var headerBorderView: UIView!
  @IBOutlet fileprivate weak var headerTopBackgroundView: UIView!
  @IBOutlet fileprivate weak var headerView: UIView!
  @IBOutlet fileprivate weak var headerViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var savedSortLabel: UILabel!

  private weak var backedProjectsViewController: ProfileBackedProjectsViewController!

  private let viewModel: BackerDashboardViewModelType = BackerDashboardViewModel()

  var previousScrollOffset: CGFloat = 0;

  internal static func instantiate() -> BackerDashboardViewController {
    return Storyboard.BackerDashboard.instantiate(BackerDashboardViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.backedProjectsViewController = self.childViewControllers
      .flatMap { $0 as? ProfileBackedProjectsViewController }.first

    self.backedProjectsViewController.delegate = self
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()
  }

  internal override func bindStyles() {
    super.bindStyles()
  }
}

extension BackerDashboardViewController: ProfileBackedProjectsViewControllerDelegate {
  func profileBackedProjectsDidScroll(_ scrollView: UIScrollView) {
    let minHeaderHeight = self.headerView.frame.size.height - self.headerTopBackgroundView.frame.size.height
      + Styles.grid(2)

    // super basic
    self.headerViewTopConstraint.constant = -scrollView.contentOffset.y

    if self.headerViewTopConstraint.constant <= -minHeaderHeight {
      self.headerViewTopConstraint.constant = -minHeaderHeight
    }
  }

  func profileBackedProjectsDidEndDecelerating(_ scrollView: UIScrollView) {
  }

  func profileBackedProjectsDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
    }
  }
}

