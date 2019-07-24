import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private let viewModel = PledgePaymentMethodsViewModel()

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var collectionView: UICollectionView = {
    UICollectionView(frame: .zero, collectionViewLayout: self.layout)
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.always
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var collectionViewHeightConstraint: NSLayoutConstraint = {
    self.collectionView.heightAnchor.constraint(equalToConstant: 0)
      |> \.priority .~ .defaultHigh
  }()

  private let dataSource = PledgePaymentMethodsDataSource()

  private lazy var layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.sectionInset .~ UIEdgeInsets.zero
      |> \.scrollDirection .~ .horizontal
      |> \.estimatedItemSize .~ UICollectionViewFlowLayout.automaticSize
  }()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureSubviews()
  }

  private func configureSubviews() {
    _ = ([self.applePayButton, self.titleLabel, self.collectionView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = self.collectionView
      |> \.dataSource .~ self.dataSource

    self.collectionView.register(PledgeCreditCardCell.self)

    NSLayoutConstraint.activate([
      self.collectionViewHeightConstraint,
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])

    self.applePayButton.addTarget(
      self,
      action: #selector(PledgePaymentMethodsViewController.applePayButtonTapped),
      for: .touchUpInside
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateCollectionViewConstraints()
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
  }

  // MARK: - Configuration

  internal func configureWith(value: [GraphUserCreditCard.CreditCard]) {
    self.viewModel.inputs.configureWith(value)
  }

  // MARK: - Actions

  @objc private func applePayButtonTapped() {
    print("Apple Pay tapped")
  }

  // MARK: - Private Functions
  private func updateCollectionViewConstraints() {
    self.collectionView.layoutIfNeeded()

    self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height

    self.view.setNeedsLayout()
  }
}
