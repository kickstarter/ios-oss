import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardViewController: UIViewController {

  @IBOutlet private weak var avatarView: CircleAvatarImageView!
  @IBOutlet private weak var backedContainerView: UIView!
  @IBOutlet private weak var backedSortButton: UIButton!
  @IBOutlet private weak var backerNameLabel: UILabel!
  @IBOutlet private weak var backerNumberLabel: UILabel!
  @IBOutlet private weak var dividerView: UIView!
  @IBOutlet fileprivate weak var headerTopBackgroundView: UIView!
  @IBOutlet fileprivate weak var headerView: UIView!
  @IBOutlet fileprivate weak var headerViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var savedContainerView: UIView!
  @IBOutlet private weak var savedSortButton: UIButton!
  @IBOutlet private weak var selectedLineView: UIView!
  @IBOutlet private weak var selectedLineLeadingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var selectedLineWidthConstraint: NSLayoutConstraint!

  private weak var backedProjectsViewController: ProfileBackedProjectsViewController!
  private weak var savedProjectsViewController: ProfileSavedProjectsViewController!

  private let viewModel: BackerDashboardViewModelType = BackerDashboardViewModel()

  private var currentScrollOffset: CGFloat = 0 // temp
  private var isCollapsed: Bool = false

  internal static func instantiate() -> BackerDashboardViewController {
    return Storyboard.BackerDashboard.instantiate(BackerDashboardViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.backedProjectsViewController = self.childViewControllers
      .flatMap { $0 as? ProfileBackedProjectsViewController }.first

    self.backedProjectsViewController.delegate = self

    self.savedProjectsViewController = self.childViewControllers
      .flatMap { $0 as? ProfileSavedProjectsViewController }.first

    self.savedProjectsViewController.delegate = self

    self.savedProjectsViewController.view.isHidden = true
    self.savedContainerView.isHidden = true

    self.backedSortButton.addTarget(self, action: #selector(backedButtonTapped), for: .touchUpInside)

    self.savedSortButton.addTarget(self, action: #selector(savedButtonTapped), for: .touchUpInside)
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

  fileprivate func moveHeader(with scrollView: UIScrollView) {
    let minHeaderHeight = self.headerView.frame.size.height - self.headerTopBackgroundView.frame.size.height
      + Styles.grid(2)

    if scrollView.contentOffset.y > 0 {
      self.headerViewTopConstraint.constant = -scrollView.contentOffset.y
    }

    if self.headerViewTopConstraint.constant <= -minHeaderHeight {
      self.headerViewTopConstraint.constant = -minHeaderHeight
      isCollapsed = true
    } else {
      isCollapsed = false
    }

    self.currentScrollOffset = abs(self.headerViewTopConstraint.constant)

    print("offset = \(scrollView.contentOffset.y)")
  }

  @objc private func backedButtonTapped() {
    self.backedProjectsViewController.view.isHidden = false
    self.backedContainerView.isHidden = false
    self.savedProjectsViewController.view.isHidden = true
    self.savedContainerView.isHidden = true

    self.selectedLineLeadingConstraint.constant = 0
    self.selectedLineWidthConstraint.constant = self.backedSortButton.frame.size.width
  }

  @objc private func savedButtonTapped() {
    self.backedProjectsViewController.view.isHidden = true
    self.backedContainerView.isHidden = true
    self.savedProjectsViewController.view.isHidden = false
    self.savedContainerView.isHidden = false

    self.selectedLineLeadingConstraint.constant = self.savedSortButton.frame.origin.x
    self.selectedLineWidthConstraint.constant = self.savedSortButton.frame.size.width
  }
}

extension BackerDashboardViewController: ProfileBackedProjectsViewControllerDelegate {
  func profileBackedProjectsDidScroll(_ scrollView: UIScrollView) {
    self.moveHeader(with: scrollView)
  }

  func profileBackedProjectsDidEndDecelerating(_ scrollView: UIScrollView) {
  }

  func profileBackedProjectsDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
    }
  }
}

extension BackerDashboardViewController: ProfileSavedProjectsViewControllerDelegate {
  func profileSavedProjectsDidScroll(_ scrollView: UIScrollView) {
    self.moveHeader(with: scrollView)
  }

  func profileSavedProjectsDidEndDecelerating(_ scrollView: UIScrollView) {
  }

  func profileSavedProjectsDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
    }
  }
}

