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

  func configure(with reward: Reward) {
    self.pledgeTableViewController.configure(with: reward)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in "Back this project" }

    if let childView = self.pledgeTableViewController.tableView {
      self.addChild(self.pledgeTableViewController)
      self.view.addSubview(childView)
      self.pledgeTableViewController.didMove(toParent: self)

      childView.constrainEdges(to: self.view)
    }
  }
}
