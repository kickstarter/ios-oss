import Foundation
import Library
import Prelude

final class SettingsFormFieldView: UIView, NibLoading {
  // swiftlint:disable private_outlet
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var titleLabel: UILabel!
  // swiftlint:enable private_outlets
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var stackView: UIStackView!

  var autocapitalizationType: UITextAutocapitalizationType = .none
  var returnKeyType: UIReturnKeyType = .default

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    guard let view = self.view(fromNib: .SettingsFormFieldView) else {
      fatalError("Failed to load view")
    }

    view.frame = self.bounds

    self.addSubview(view)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsTitleLabelStyle
      |> \.isAccessibilityElement .~ false
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.textField
      |> formFieldStyle
      |> \.autocapitalizationType .~ self.autocapitalizationType
      |> \.returnKeyType .~ self.returnKeyType
      |> \.textAlignment .~ .right
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.accessibilityLabel .~ self.titleLabel.text

    _ = self.separatorView
      |> separatorStyle
  }
}
