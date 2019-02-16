import Library
import Prelude
import UIKit

final class SettingsTextInputCell: UITableViewCell {
  // MARK: - Accessors

  private lazy var stackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.spacing .~ 8
  }()

  private lazy var label: UILabel = {
    UILabel(frame: .zero)
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.backgroundColor .~ .white
      |> \.font .~ UIFont.preferredFont(forTextStyle: .body)
      |> \.isAccessibilityElement .~ false
      |> \.numberOfLines .~ 0
  }()

  private lazy var textField: UITextField = {
    UITextField(frame: .zero)
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.backgroundColor .~ .white
      |> \.font .~ UIFont.preferredFont(forTextStyle: .body)
      |> \.textAlignment .~ .right
      |> \.isSecureTextEntry .~ true
  }()

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

    _ = self.contentView
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(1))
      |> \.preservesSuperviewLayoutMargins .~ false

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

  // MARK: - Layout

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    let traitCollection = self.traitCollection

    if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
      self.configure(with: traitCollection)
    }
  }

  private func configure(with traitCollection: UITraitCollection) {
    let contentSize = traitCollection.preferredContentSizeCategory

    if contentSize.ksr_isAccessibilityCategory() {
      self.stackView.axis = .vertical
      self.stackView.alignment = .leading
      self.textField.textAlignment = .left
    } else {
      self.stackView.axis = .horizontal
      self.stackView.alignment = .fill
      self.textField.textAlignment = .right
    }
  }
}

// MARK: - Extensions

private extension UIContentSizeCategory {
  func ksr_isAccessibilityCategory() -> Bool {
    if #available(iOS 11, *) {
      return self.isAccessibilityCategory
    } else {
      return
        self == .accessibilityMedium ||
        self == .accessibilityLarge ||
        self == .accessibilityExtraLarge ||
        self == .accessibilityExtraExtraLarge ||
        self == .accessibilityExtraExtraExtraLarge
    }
  }
}
