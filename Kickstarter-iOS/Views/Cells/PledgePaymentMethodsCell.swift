import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodsCell: UITableViewCell, ValueCell {

  private let cellIdentifier = "Cell"

  // MARK: - Properties

  private lazy var collectionView: UICollectionView = {
    UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
      |> \.dataSource .~ self
      |> \.delegate .~ self
  }()

  private lazy var headerStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.configureSubviews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self
      |> checkoutBackgroundStyle

    _ = self.collectionView
      |> \.backgroundColor .~ .white

    _ = self.headerStackView
      |> checkoutStackViewStyle

    _ = self.titleLabel
      |> \.text %~ { _ in Strings.Other_payment_methods() }
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500
      |> \.textAlignment .~ .center
  }

  override func bindViewModel() {
    super.bindViewModel()
  }

  private func configureSubviews() {
    _ = (self.headerStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.collectionView], self.headerStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  func configureWith(value: [GraphUserCreditCard]) {
  }
}

extension PledgePaymentMethodsCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    return cell
  }
}

extension PledgePaymentMethodsCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}
