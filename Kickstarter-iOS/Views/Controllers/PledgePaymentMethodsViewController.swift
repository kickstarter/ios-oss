import KsApi
import Library
import PassKit
import Prelude
import UIKit

<<<<<<< HEAD:Kickstarter-iOS/Views/Controllers/PledgePaymentMethodsViewController.swift
final class PledgePaymentMethodsViewController: UIViewController {
=======
private enum Layout {
  enum Card {
    static let height: CGFloat = 136
    static let width: CGFloat = 240
  }
}

final class PledgePaymentMethodsCell: UITableViewCell, ValueCell {
>>>>>>> 1972b6037... Created PledgePaymentMethodsDataSource:Kickstarter-iOS/Views/Cells/PledgePaymentMethodsCell.swift
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(frame: .zero, collectionViewLayout: self.layout)
  }()

<<<<<<< HEAD:Kickstarter-iOS/Views/Controllers/PledgePaymentMethodsViewController.swift
  private let layout: UICollectionViewLayout = {
    UICollectionViewFlowLayout()
      |> \.scrollDirection .~ .horizontal
  }()
=======
  private let dataSource = PledgePaymentMethodsDataSource()
>>>>>>> 1972b6037... Created PledgePaymentMethodsDataSource:Kickstarter-iOS/Views/Cells/PledgePaymentMethodsCell.swift

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.applePayButton, self.titleLabel, self.collectionView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

<<<<<<< HEAD:Kickstarter-iOS/Views/Controllers/PledgePaymentMethodsViewController.swift
    NSLayoutConstraint.activate([
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])

    self.applePayButton.addTarget(
      self,
      action: #selector(PledgePaymentMethodsViewController.applePayButtonTapped),
      for: .touchUpInside
    )
=======
    _ = self.collectionView
      |> \.dataSource .~ self.dataSource
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    self.collectionView.register(PledgeCreditCardCell.self)

    self.collectionView.heightAnchor.constraint(equalToConstant: 140)
>>>>>>> 1972b6037... Created PledgePaymentMethodsDataSource:Kickstarter-iOS/Views/Cells/PledgePaymentMethodsCell.swift
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.applePayButton
      |> roundedStyle(cornerRadius: Styles.grid(2))
      |> \.isAccessibilityElement .~ true

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

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
  }

<<<<<<< HEAD:Kickstarter-iOS/Views/Controllers/PledgePaymentMethodsViewController.swift
  // MARK: - Configuration

  internal func configureWith(value _: [GraphUserCreditCard]) {}

  // MARK: - Actions

  @objc private func applePayButtonTapped() {
    print("Apple Pay tapped")
  }
}

extension PledgePaymentMethodsViewController: UICollectionViewDataSource {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    return 1
=======
  internal func configureWith(value: [GraphUserCreditCard.CreditCard]) {
    self.dataSource.load(creditCards: value)
    self.collectionView.reloadData()
>>>>>>> 1972b6037... Created PledgePaymentMethodsDataSource:Kickstarter-iOS/Views/Cells/PledgePaymentMethodsCell.swift
  }
}

extension PledgePaymentMethodsCell: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
    return CGSize(width: Layout.Card.width, height: Layout.Card.height)
  }
}
