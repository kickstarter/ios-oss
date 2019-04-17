import Library
import Prelude
import UIKit

public typealias TextFieldTargetAction = (target: Any?, action: Selector, event: UIControl.Event)

final class SettingsTextInputCell: UITableViewCell {
  // MARK: - Properties

  private lazy var stackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private(set) lazy var textField: UITextField = { UITextField(frame: .zero) }()

  public func configure(with placeholder: String, returnKeyType: UIReturnKeyType, title: String) {
    _ = self.label
      |> \.text .~ title

    _ = self.textField
      |> \.placeholder .~ placeholder
      |> \.accessibilityLabel .~ self.label.accessibilityLabel
      |> \.returnKeyType .~ returnKeyType
  }

  public func configure(with targetActions: [TextFieldTargetAction]) {
    targetActions.forEach { target, action, event in
      self.textField.addTarget(target, action: action, for: event)
    }
  }

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.stackView.addArrangedSubview(self.label)
    self.stackView.addArrangedSubview(self.textField)

    self.label.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.label.setContentHuggingPriority(.required, for: .horizontal)

    self.textField.setContentHuggingPriority(.defaultLow, for: .horizontal)

    _ = (self.stackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectionStyle .~ .none

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
