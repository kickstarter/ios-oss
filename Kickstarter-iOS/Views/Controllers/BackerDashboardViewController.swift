import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardViewController: UIViewController {

  private let viewModel: BackerDashboardViewModelType = BackerDashboardViewModel()

  internal static func instantiate() -> BackerDashboardViewController {
    return Storyboard.BackerDashboard.instantiate(BackerDashboardViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
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

