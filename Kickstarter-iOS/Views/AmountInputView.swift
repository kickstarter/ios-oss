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

    // Align label's ascender to text field's ascender
    if let textFieldFont = self.textField.font, let labelFont = self.label.font {
      let constant = (textFieldFont.capHeight - labelFont.capHeight) / 2

      self.labelCenterYAnchor = NSLayoutConstraint(
        item: self.label,
        attribute: .centerY,
        relatedBy: .equal,
        toItem: self.textField,
        attribute: .centerY,
        multiplier: 1,
        constant: -constant
      )
      self.labelCenterYAnchor?.isActive = true
    }
  }

  // MARK: - Configuration

  private func configureView(for traitCollection: UITraitCollection) {
    let isAccessibilityCategory = self.traitCollection.ksr_isAccessibilityCategory()

    _ = self.stackView
      |> \.layoutMargins .~ UIEdgeInsets(all: isAccessibilityCategory ? Styles.grid(2) : Styles.grid(1))
  }

  func configureWith(amount: Double, placeholder: Double, currency: String) {
    _ = self.label
      |> \.text .~ currency

    _ = self.textField
      |> \.placeholder .~ "\(placeholder)"
      |> \.text .~ "\(amount)"
  }
}

private let labelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ .right
    |> \.textColor .~ UIColor.ksr_green_500
}

private let textFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_title1()
    |> \.keyboardType .~ .decimalPad
    |> \.textColor .~ UIColor.ksr_green_500
}

private let stackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ .top
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let viewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.white
    |> \.layer.cornerRadius .~ 6
}
