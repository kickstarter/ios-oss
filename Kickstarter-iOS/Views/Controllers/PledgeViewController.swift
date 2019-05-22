import Library
import KsApi
import Prelude
import UIKit

final class PledgeViewController: UIViewController {
  // MARK: - Properties

  private lazy var pledgeTableViewController: PledgeTableViewController = {
    PledgeTableViewController.instantiate()
  }()

  // MARK: - Lifecycle

  static func instantiate() -> PledgeViewController {
    return PledgeViewController()
  }

  func configureWith(project: Project, reward: Reward) {
    self.pledgeTableViewController.configureWith(project: project, reward: reward)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Back_this_project() }

    if let childView = self.pledgeTableViewController.tableView {
      self.addChild(self.pledgeTableViewController)
      _ = (childView, self.view) |> ksr_addSubviewToParent()
      self.pledgeTableViewController.didMove(toParent: self)

      _ = (childView, self.view) |> ksr_constrainViewToEdgesInParent()
    }
  }
}
