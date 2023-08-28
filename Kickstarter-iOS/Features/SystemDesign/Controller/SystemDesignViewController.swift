import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class SystemDesignViewController: UITableViewController {
  // MARK: - Properties

  static func instantiate() -> SystemDesignViewController {
    return SystemDesignViewController(style: .plain)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "System Design"
  }
}
