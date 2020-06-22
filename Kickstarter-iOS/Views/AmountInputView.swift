import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 34
  }

  enum Toolbar {
    static let height: CGFloat = 54
  }
}

class AmountInputView: UIView {
  // MARK: - Properties

  private(set) lazy var doneButton: UIButton = {
    UIButton(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private(set) lazy var label: UILabel = { UILabel(frame: .zero) }()
  private(set) lazy var textField: UITextField = {
    UITextField(frame: .zero)
      |> \.inputAccessoryView .~ self.toolbar
  }()

  private lazy var toolbar: UIToolbar = {
    UIToolbar(frame: .zero)
      |> \.items .~ [
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        UIBarButtonItem(customView: self.doneButton)
      ]
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var stackView: UIStackView = { UIStackView(frame: .zero) }()
  private var labelCenterYAnchor: NSLayoutConstraint?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.stackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.label, self.textField], self.stackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.toolbar.sizeToFit()

    NSLayoutConstraint.activate([
      self.doneButton.heightAnchor.constraint(equalToConstant: Layout.Button.height),
      self.toolbar.heightAnchor.constraint(equalToConstant: Layout.Toolbar.height)
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutWhiteBackgroundStyle
      |> checkoutRoundedCornersStyle

    _ = self.doneButton
      |> keyboardDoneButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Done() }

    _ = self.label
      |> labelStyle

    _ = self.textField
      |> textFieldStyle

    _ = self.toolbar
      |> keyboardToolbarStyle

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.stackView
      |> stackViewStyle
      |> \.layoutMargins .~ UIEdgeInsets(all: isAccessibilityCategory ? Styles.grid(2) : Styles.grid(1))

    constrainAscenders(between: self.label, textField: self.textField)
  }

  // MARK: - Configuration

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
    |> \.font .~ UIFont.ksr_body()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
}

private let textFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_title1().monospaced
    |> \.keyboardType .~ UIKeyboardType.decimalPad
}

private let stackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

// MARK: - Functions

/// Aligns label's ascender to text field's ascender or vice versa
private func constrainAscenders(between label: UILabel, textField: UITextField) {
  guard let labelFont = label.font, let textFieldFont = textField.font else { return }

  let maxCapHeight = max(labelFont.capHeight, textFieldFont.capHeight)
  let minCapHeight = min(labelFont.capHeight, textFieldFont.capHeight)
  let constant = (maxCapHeight - minCapHeight) / 2

  _ = label.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: -constant)
    |> \.priority .~ .defaultHigh
    |> \.isActive .~ true
}
