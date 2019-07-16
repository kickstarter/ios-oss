import KsApi
import Library
import PassKit
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

  private let viewModel = PledgePaymentMethodsCellViewModel()

  private var collectionViewHeightAnchor: NSLayoutConstraint!

  private lazy var layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.scrollDirection .~ .horizontal
      |> \.estimatedItemSize .~ CGSize(width: Layout.Card.width, height: Layout.Card.height)
  }()

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

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
    _ = ([self.applePayButton, self.titleLabel, self.collectionView], self.rootStackView)
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

    NSLayoutConstraint.activate([
      self.collectionViewHeightAnchor,
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])

    self.applePayButton.addTarget(
      self,
      action: #selector(PledgePaymentMethodsCell.applePayButtonTapped),
      for: .touchUpInside
    )
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self
      |> checkoutBackgroundStyle

    _ = self.applePayButton
      |> roundedStyle(cornerRadius: Styles.grid(2))
      |> \.isAccessibilityElement .~ true

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

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(creditCards: $0)
        self?.collectionView.reloadData()
        self?.collectionView.layoutIfNeeded()
      }

    self.viewModel.outputs.updateConstraints
      .observeForUI()
      .observeValues { [weak self] in
        self?.updateConstraints($0)
      }
  }

  // MARK: - Configuration

  internal func configureWith(value: [GraphUserCreditCard.CreditCard]) {
    self.viewModel.inputs.configureWith(value)
  }

  // MARK: - Actions

  @objc private func applePayButtonTapped() {
    print("Apple Pay tapped")
  }

  func collectionView(
    _: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    if let cell = cell as? PledgeCreditCardCell, cell.delegate == nil {
      cell.delegate = self
    }
  }

  // MARK: - Private Functions

  private func updateConstraints(_ size: CGSize) {
    NSLayoutConstraint.deactivate([self.collectionViewHeightAnchor])
    self.collectionViewHeightAnchor =
      self.collectionView.heightAnchor.constraint(equalToConstant: size.height + Styles.grid(2))
    NSLayoutConstraint.activate([self.collectionViewHeightAnchor])
    self.layoutIfNeeded()
  }
}

extension PledgePaymentMethodsCell: UICollectionViewDelegate {
  func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {}
}

extension PledgePaymentMethodsCell: PledgeCreditCardCellDelegate {
  func didUpdateContentSize(_: PledgeCreditCardCell, size: CGSize) {
    self.viewModel.inputs.didUpdateContentSize(size)
  }
}
