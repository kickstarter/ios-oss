import KsApi
import Library
import Prelude
import UIKit

internal final class CreatorDigestSettingsViewController: UIViewController {
  fileprivate let viewModel: CreatorDigestSettingsViewModelType = CreatorDigestSettingsViewModel()

  internal static func instantiate() -> CreatorDigestSettingsViewController {
    return Storyboard.Settings.instantiate(CreatorDigestSettingsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()
  }

  internal override func bindViewModel() {

  }
}
