import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private let viewModel = PledgePaymentMethodsViewModel()

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
    self.scrollView.heightAnchor.constraint(equalToConstant: 0)
  }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
  }

  private func configureSubviews() {
    _ = ([self.applePayButton, self.titleLabel, self.scrollView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    NSLayoutConstraint.activate([
      self.scrollViewHeightConstraint,
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

    self.updateScrollViewHeightConstraint()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    self.updateScrollViewHeightConstraint()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.applePayButton
      |> roundedStyle(cornerRadius: Styles.grid(2))
      |> \.isAccessibilityElement .~ true

    _ = self.scrollView
      |> checkoutBackgroundStyle

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
      .observeValues { [weak self] cards in
        self?.populateScrollView(with: cards)
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

  // MARK: - Functions

  private func populateScrollView(with cards: [GraphUserCreditCard.CreditCard]) {
    self.scrollView.subviews.forEach { $0.removeFromSuperview() }

    var previousAnchor = self.scrollView.leadingAnchor
    var spacing: CGFloat = 0

    for card in cards {
      let cardView = PledgeCreditCardView(frame: .zero)
        |> \.translatesAutoresizingMaskIntoConstraints .~ false

      cardView.configureWith(value: card)
      self.scrollView.addSubview(cardView)

      NSLayoutConstraint.activate([
        cardView.leadingAnchor.constraint(equalTo: previousAnchor, constant: spacing),
        cardView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
        cardView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
      ])

      if card == cards.last {
        cardView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
      }

      spacing = Styles.grid(2)
      previousAnchor = cardView.trailingAnchor
    }
  }

  private func updateScrollViewHeightConstraint() {
    self.scrollViewHeightConstraint.constant = self.scrollView.contentSize.height

    self.view.layoutIfNeeded()
  }
}
