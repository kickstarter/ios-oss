import Foundation
import Library
import Prelude

@IBDesignable final class SettingsFormFieldView: UIView, NibLoading {
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var separatorView: UIView!

  public static func instantiate() -> SettingsFormFieldView {
    guard let view = SettingsFormFieldView.fromNib(nib: Nib.SettingsFormFieldView) else {
      fatalError("failed to load LoadingBarButtonItemView from Nib")
    }

    return view
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsTitleLabelStyle
      |> \.isAccessibilityElement .~ false

    _ = self.textField
      |> formFieldStyle
      |> \.autocapitalizationType .~ .words
      |> \.returnKeyType .~ .next
      |> \.textAlignment .~ .right
      |> \.textColor .~ .ksr_text_dark_grey_500

    _ = self.separatorView
      |> separatorStyle
  }
}
