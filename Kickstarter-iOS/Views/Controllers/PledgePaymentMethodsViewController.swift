import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol PledgePaymentMethodsViewControllerDelegate: AnyObject {
  func pledgePaymentMethodsViewControllerDidTapApplePayButton(
    _ viewController: PledgePaymentMethodsViewController
  )
}

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()
  private lazy var cardsStackView: UIStackView = { UIStackView(frame: .zero) }()
  internal weak var delegate: PledgePaymentMethodsViewControllerDelegate?
  internal weak var messageDisplayingDelegate: PledgeViewControllerMessageDisplaying?
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var scrollViewContainer: UIView = { UIView(frame: .zero) }()
  private lazy var spacer: UIView = { UIView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel = PledgePaymentMethodsViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.scrollView, self.scrollViewContainer)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.cardsStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.applePayButton, self.spacer, self.titleLabel, self.scrollViewContainer], self.rootStackView)
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
      self.cardsStackView.heightAnchor.constraint(equalTo: self.scrollViewContainer.heightAnchor),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.cardsStackView
      |> self.cardsStackViewStyle

    _ = self.applePayButton
      |> applePayButtonStyle

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

    self.viewModel.outputs.notifyDelegateLoadPaymentMethodsError
      .observeForUI()
      .observeValues { [weak self] errorMessage in
        guard let self = self else { return }

        self.messageDisplayingDelegate?.pledgeViewController(self, didErrorWith: errorMessage)
      }

    self.viewModel.outputs.notifyDelegateApplePayButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.delegate?.pledgePaymentMethodsViewControllerDidTapApplePayButton(self)
      }

    self.applePayButton.rac.hidden = self.viewModel.outputs.applePayButtonHidden
  }

  // MARK: - Configuration

  func configure(with value: (user: User, project: Project)) {
    let pledgePaymentMethodsValue = PledgePaymentMethodsValue(
      user: value.user,
      project: value.project,
      applePayCapable: PKPaymentAuthorizationViewController.applePayCapable(for: value.project)
    )

    self.viewModel.inputs.configureWith(pledgePaymentMethodsValue)
  }

  // MARK: - Actions

  @objc private func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
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

  // MARK: - Styles

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
