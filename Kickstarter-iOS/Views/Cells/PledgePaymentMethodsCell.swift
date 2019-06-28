import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodsCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let layout: UICollectionViewLayout = {
    UICollectionViewFlowLayout()
      |> \.scrollDirection .~ .horizontal
  }()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(frame: .zero, collectionViewLayout: self.layout)
      |> \.dataSource .~ self
  }()

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
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self
      |> checkoutBackgroundStyle

    _ = self.collectionView
      |> \.backgroundColor .~ .white

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

  internal func configureWith(value _: [GraphUserCreditCard]) {}
}

extension PledgePaymentMethodsCell: UICollectionViewDataSource {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: UICollectionViewCell.defaultReusableId,
      for: indexPath
    )
    return cell
  }
}
