import Library
import Prelude
import UIKit

final class SettingsTextInputCell: UITableViewCell {
  // MARK: - Properties

  private lazy var stackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private lazy var textField: UITextField = { UITextField(frame: .zero) }()

  public func configure(with title: String, placeholder: String) {
    _ = self.label
      |> \.text .~ title

    _ = self.textField
      |> \.placeholder .~ placeholder
      |> \.accessibilityLabel .~ self.label.accessibilityLabel
  }

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.stackView.addArrangedSubview(self.label)
    self.stackView.addArrangedSubview(self.textField)

    self.label.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.label.setContentHuggingPriority(.required, for: .horizontal)

    self.textField.setContentHuggingPriority(.defaultLow, for: .horizontal)

    self.contentView.addSubviewConstrainedToMargins(self.stackView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> settingsContentViewStyle

    _ = self.stackView
      |> settingsStackViewStyle

    _ = self.label
      |> settingsLabelStyle
      |> \.isAccessibilityElement .~ false
      |> \.numberOfLines .~ 0

    _ = self.textField
      |> settingsTextFieldStyle
      |> \.isSecureTextEntry .~ true
  }
}
