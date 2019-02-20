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

    let preferredContentSizeCategory = self.traitCollection.preferredContentSizeCategory
    let isAccessibilityCategory = preferredContentSizeCategory.ksr_isAccessibilityCategory()

    _ = self.contentView
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(1))
      |> \.preservesSuperviewLayoutMargins .~ false

    _ = self.stackView
      |> \.axis .~ (isAccessibilityCategory ? .vertical : .horizontal)
      |> \.alignment .~ (isAccessibilityCategory ? .leading : .fill)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.spacing .~ 8

    _ = self.label
      |> \.backgroundColor .~ .white
      |> \.font %~ { _ in .ksr_body() }
      |> \.isAccessibilityElement .~ false
      |> \.numberOfLines .~ 0

    _ = self.textField
      |> \.backgroundColor .~ .white
      |> \.font %~ { _ in .ksr_body() }
      |> \.textAlignment .~ (isAccessibilityCategory ? .left : .right)
      |> \.isSecureTextEntry .~ true
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
