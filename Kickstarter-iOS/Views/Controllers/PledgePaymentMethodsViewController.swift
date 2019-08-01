import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private let viewModel = PledgePaymentMethodsViewModel()

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()
  private lazy var cardsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
    self.scrollView.heightAnchor.constraint(equalToConstant: 0)
  }()

  private lazy var spacer: UIView = { UIView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()
  }

  private func configureSubviews() {
    _ = (self.cardsStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.applePayButton, self.spacer, self.titleLabel, self.scrollView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.applePayButton.addTarget(
      self,
      action: #selector(PledgePaymentMethodsViewController.applePayButtonTapped),
      for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.scrollViewHeightConstraint,
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateScrollViewHeightConstraint()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    self.updateScrollViewHeightConstraint()
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.cardsStackView
      |> self.cardsStackViewStyle

    _ = self.applePayButton
      |> self.applePayButtonStyle

    _ = self.scrollView
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> self.rootStackViewStyle

    _ = self.titleLabel
      |> self.titleLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
    self.viewModel.outputs.reloadPaymentMethods
      .observeForUI()
      .observeValues { [weak self] cards in
        self?.addCardsToStackView(cards)
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

  private func addCardsToStackView(_ cards: [GraphUserCreditCard.CreditCard]) {
    self.cardsStackView.arrangedSubviews.forEach(self.cardsStackView.removeArrangedSubview)

    let cardViews: [UIView] = cards
      .map { card -> PledgeCreditCardView in
        let cardView = PledgeCreditCardView(frame: .zero)
        cardView.configureWith(value: card)
        return cardView
      }

    let addNewCardView: UIView = PledgeAddNewCardView(frame: .zero)
      |> \.delegate .~ self

    _ = (cardViews + [addNewCardView], self.cardsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func updateScrollViewHeightConstraint() {
    self.scrollViewHeightConstraint.constant = self.scrollView.contentSize.height

    self.view.layoutIfNeeded()
  }

  // MARK: - Styles

  private let applePayButtonStyle: ButtonStyle = { button in
    button
      |> roundedStyle(cornerRadius: Styles.grid(2))
      |> \.isAccessibilityElement .~ true
  }

  private let cardsStackViewStyle: StackViewStyle = { stackView in
    stackView
      |> \.spacing .~ Styles.grid(2)
  }

  private let rootStackViewStyle: StackViewStyle = { stackView in
    stackView
      |> checkoutStackViewStyle
      |> \.spacing .~ Styles.grid(2)
  }

  private let titleLabelStyle: LabelStyle = { label in
    label
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Other_payment_methods() }
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500
      |> \.font .~ UIFont.ksr_caption1()
      |> \.textAlignment .~ .center
  }
}

extension PledgePaymentMethodsViewController: PledgeAddNewCardViewDelegate {
  func pledgeAddNewCardViewDidTapAddNewCard(_: PledgeAddNewCardView) {
    let addNewCardViewController = AddNewCardViewController.instantiate()
      |> \.delegate .~ self
    let navigationController = UINavigationController.init(rootViewController: addNewCardViewController)
    let offset = navigationController.navigationBar.bounds.height

    self.presentViewControllerWithSheetOverlay(navigationController, offset: offset)
  }
}

extension PledgePaymentMethodsViewController: AddNewCardViewControllerDelegate {
  func addNewCardViewControllerDismissed(_: AddNewCardViewController) {
    self.dismiss(animated: true)
  }

  func addNewCardViewController(
    _: AddNewCardViewController,
    didSucceedWithMessage _: String
  ) {
    // TODO:
  }
}
