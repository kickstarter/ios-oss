import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Card {
    static let height: CGFloat = 136
    static let width: CGFloat = 240
  }
}

final class PledgePaymentMethodsCell: UITableViewCell, ValueCell {
  // MARK: - Properties
  private var collectionViewHeightAnchor: NSLayoutConstraint!

  private lazy var layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.scrollDirection .~ .horizontal
      |> \.estimatedItemSize .~ CGSize(width: Layout.Card.width, height: Layout.Card.height)
  }()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(frame: .zero, collectionViewLayout: self.layout)
  }()

  private let dataSource = PledgePaymentMethodsDataSource()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.configureSubviews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureSubviews() {
    _ = self
      |> \.accessibilityElements .~ self.subviews

    _ = ([self.titleLabel, self.collectionView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = self.collectionView
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self

    self.collectionView.register(PledgeCreditCardCell.self)

    self.collectionViewHeightAnchor = self.collectionView.heightAnchor.constraint(
      greaterThanOrEqualToConstant: Layout.Card.height + Styles.grid(2)
    )

    NSLayoutConstraint.activate([self.collectionViewHeightAnchor])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self
      |> checkoutBackgroundStyle

    _ = self.collectionView
      |> checkoutBackgroundStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.rootStackView
      |> checkoutStackViewStyle

    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Other_payment_methods() }
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500
      |> \.font .~ UIFont.ksr_caption1()
      |> \.textAlignment .~ .center
  }

  override func bindViewModel() {
    super.bindViewModel()
  }

  internal func configureWith(value: [GraphUserCreditCard.CreditCard]) {
    self.dataSource.load(creditCards: value)
    self.collectionView.reloadData()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {
    if let cell = cell as? PledgeCreditCardCell, cell.delegate == nil {
      cell.delegate = self
    }
  }
}

extension PledgePaymentMethodsCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(collectionView)
  }
}

extension PledgePaymentMethodsCell: PledgeCreditCardCellDelegate {

  func didUpdateContentSize(_ cell: PledgeCreditCardCell, size: CGSize) {
    self.updateConstraints(size)

  }

  private func updateConstraints(_ size: CGSize) {

    NSLayoutConstraint.deactivate([self.collectionViewHeightAnchor])

    self.collectionViewHeightAnchor =
      self.collectionView.heightAnchor.constraint(equalToConstant: size.height + Styles.grid(2))

    NSLayoutConstraint.activate([self.collectionViewHeightAnchor])

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
}
