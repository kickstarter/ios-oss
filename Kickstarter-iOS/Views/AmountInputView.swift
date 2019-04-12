import Library
import Prelude
import UIKit

class AmountInputView: UIView {
  // MARK: - Properties

  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private lazy var textField: UITextField = { UITextField(frame: .zero) }()
  private lazy var stackView: UIStackView = { UIStackView(frame: .zero) }()
  private var labelCenterYAnchor: NSLayoutConstraint?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.stackView.addArrangedSubview(self.label)
    self.stackView.addArrangedSubview(self.textField)

    self.addSubviewConstrainedToEdges(self.stackView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    let traitCollection = self.traitCollection

    if previousTraitCollection?.preferredContentSizeCategory
      != traitCollection.preferredContentSizeCategory {
      self.configureView(for: traitCollection)
    }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> viewStyle

    _ = self.label
      |> labelStyle

    _ = self.textField
      |> textFieldStyle

    _ = self.stackView
      |> stackViewStyle

    constrainAscenders(between: self.label, textField: self.textField)
  }

  // MARK: - Configuration

  private func configureView(for traitCollection: UITraitCollection) {
    let isAccessibilityCategory = self.traitCollection.ksr_isAccessibilityCategory()

    _ = self.stackView
      |> \.layoutMargins .~ UIEdgeInsets(all: isAccessibilityCategory ? Styles.grid(2) : Styles.grid(1))
  }

  func configureWith(amount: String, placeholder: String, currency: String) {
    _ = self.label
      |> \.text .~ currency

    _ = self.textField
      |> \.placeholder .~ placeholder
      |> \.text .~ amount
  }
}

// MARK: - Styles

private let labelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.textColor .~ UIColor.ksr_green_500
}

private let textFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_title1()
    |> \.keyboardType .~ UIKeyboardType.decimalPad
    |> \.textColor .~ UIColor.ksr_green_500
}

private let stackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let viewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.white
    |> \.layer.cornerRadius .~ 6
}

// MARK: - Functions

/// Aligns label's ascender to text field's ascender or vice versa
private func constrainAscenders(between label: UILabel, textField: UITextField) {
  guard let labelFont = label.font, let textFieldFont = textField.font else { return }

  let maxCapHeight = max(labelFont.capHeight, textFieldFont.capHeight)
  let minCapHeight = min(labelFont.capHeight, textFieldFont.capHeight)
  let constant = (maxCapHeight - minCapHeight) / 2

  label.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: -constant).isActive = true
}
