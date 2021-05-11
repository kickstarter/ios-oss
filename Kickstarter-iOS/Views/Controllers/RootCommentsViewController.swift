import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class RootCommentsViewController: UITableViewController {
  // MARK: - Properties

  fileprivate let viewModel: RootCommentsViewModelType = RootCommentsViewModel()

  // MARK: - Lifecycle

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  internal override func bindStyles() {
    super.bindStyles()
  }

  // MARK: - View Model

  internal override func bindViewModel() {}
}
