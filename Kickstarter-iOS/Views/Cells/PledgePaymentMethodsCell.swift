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

  private lazy var layout: UICollectionViewLayout = {
    UICollectionViewFlowLayout()
      |> \.scrollDirection .~ .horizontal
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

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.collectionView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = self.collectionView
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self

    self.collectionView.register(PledgeCreditCardCell.self)

    let heightConstraint = self.collectionView.heightAnchor
      .constraint(greaterThanOrEqualToConstant: Layout.Card.height + Styles.grid(2))

    NSLayoutConstraint.activate([heightConstraint])
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
}

extension PledgePaymentMethodsCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(collectionView)
  }
}

extension PledgePaymentMethodsCell: UICollectionViewDelegateFlowLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: Layout.Card.width, height: UIView.layoutFittingCompressedSize.height)

    return self.contentView.systemLayoutSizeFitting(size,
                                                    withHorizontalFittingPriority: .defaultHigh,
                                                    verticalFittingPriority: .defaultLow)
  }
}
