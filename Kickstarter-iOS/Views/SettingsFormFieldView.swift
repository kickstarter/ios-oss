import Foundation
import Library
import Prelude

final class SettingsFormFieldView: UIView, NibLoading {
  // swiftlint:disable private_outlet
  @IBOutlet var textField: UITextField!
  @IBOutlet var titleLabel: UILabel!
  // swiftlint:enable private_outlets
  @IBOutlet fileprivate var separatorView: UIView!
  @IBOutlet fileprivate var stackView: UIStackView!

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
      |> titleLabelStyle

    _ = self.textField
      |> formFieldStyle
      |> textFieldStyle
      |> \.autocapitalizationType .~ self.autocapitalizationType
      |> \.returnKeyType .~ self.returnKeyType
      |> \.accessibilityLabel .~ self.titleLabel.text

    _ = self.separatorView
      |> separatorStyle
  }
}

// MARK: - Styles

private let titleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.isAccessibilityElement .~ false
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let textFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
}
