import UIKit
import KsApi
import Models
import ReactiveCocoa
import ReactiveExtensions

class FirstViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    Service.shared.fetchProjects(DiscoveryParams())
      .uncollect()
      .map { $0.name }
      .startWithNext { name in
        print(name)
    }
  }
}
