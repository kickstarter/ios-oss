import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class RootCommentsViewController: UITableViewController {
  fileprivate let viewModel: RootCommentsViewModelType = RootCommentsViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()
  }

  internal override func bindViewModel() {}
}
