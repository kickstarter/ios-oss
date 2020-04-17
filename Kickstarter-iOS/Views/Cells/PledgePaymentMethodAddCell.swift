import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodAddCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var selectionView: UIView = { UIView(frame: .zero) }()
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

    _ = self.addButton.heightAnchor.constraint(equalToConstant: Styles.grid(9))
      |> \.priority .~ .defaultHigh
      |> \.isActive .~ true
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.selectionView
      |> selectionViewStyle

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
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.New_payment_method() }
    |> UIButton.lens.titleLabel.font .~ UIFont.boldSystemFont(ofSize: 15)
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "icon-add-round-green")
    |> UIButton.lens.isUserInteractionEnabled .~ false
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_500
    |> UIButton.lens.tintColor .~ .ksr_green_500
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(3))
}

private let selectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_grey_200
}
