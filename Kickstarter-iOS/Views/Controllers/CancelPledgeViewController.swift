import Foundation
import UIKit
import Prelude
import Library
import KsApi

final class CancelPledgeViewController: UIViewController {
  private let viewModel: CancelPledgeViewModelType = CancelPledgeViewModel()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Cancel_pledge()
    }
  }

  // MARK: - Configuration
  internal func configure(with project: Project, backing: Backing) {
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ UIColor.ksr_grey_400
  }

  override func bindViewModel() {
    super.bindViewModel()
  }
}
