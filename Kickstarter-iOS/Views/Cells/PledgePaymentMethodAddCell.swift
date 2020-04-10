import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodAddCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var selectionView: UIView = { UIView(frame: .zero) |> \.backgroundColor .~ .ksr_grey_200 }()
  // TODO: convert to label and image in stackview
  private lazy var addButton: UIButton = { UIButton(type: .custom) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    _ = (self.addButton, self.contentView)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    _ = (self.addButton, self.contentView)
      |> ksr_constrainViewToEdgesInParent()
      |> ksr_constrainViewToCenterInParent()

    self.addButton.heightAnchor.constraint(equalToConstant: Styles.grid(9)).isActive = true
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectedBackgroundView .~ self.selectionView

    _ = self.addButton
      |> addButtonStyle
  }

  func configureWith(value _: Void) {}
}

// MARK: - Styles

private let addButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in
      localizedString(
        key: "New_payment_method",
        defaultValue: "New payment method"
      )
    }
    |> UIButton.lens.titleLabel.font .~ .ksr_subhead()
    |> \.isUserInteractionEnabled .~ false
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_500
    |> \.tintColor .~ .ksr_green_500
}
