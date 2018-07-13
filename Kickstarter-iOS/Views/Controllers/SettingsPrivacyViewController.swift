import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsPrivacyViewController: UIViewController {
  private let viewModel: SettingsPrivacyViewModelType = SettingsPrivacyViewModel()

  internal static func instantiate() -> SettingsPrivacyViewController {
    return Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Privacy() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()
  }
}
