import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol PledgePaymentMethodsViewControllerDelegate: AnyObject {
  func pledgePaymentMethodsViewControllerDidTapApplePayButton(
    _ viewController: PledgePaymentMethodsViewController
  )
  func pledgePaymentMethodsViewController(
    _ viewController: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSourceId: String
  )
}

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()
  private lazy var applePaySectionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var cardsStackView: UIStackView = { UIStackView(frame: .zero) }()
  internal weak var delegate: PledgePaymentMethodsViewControllerDelegate?
  internal weak var messageDisplayingDelegate: PledgeViewControllerMessageDisplaying?
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var spacer: UIView = { UIView(frame: .zero) }()
  private lazy var storedPaymentMethodsTitleLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let applePaySectionViews = [
      self.applePayButton,
      self.spacer,
      self.storedPaymentMethodsTitleLabel
    ]

    _ = (applePaySectionViews, applePaySectionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.cardsStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([applePaySectionStackView, self.scrollView], self.rootStackView)
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
      self.scrollView.heightAnchor.constraint(equalTo: self.cardsStackView.heightAnchor),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.cardsStackView
      |> cardsStackViewStyle

    _ = self.applePayButton
      |> applePayButtonStyle

    _ = self.scrollView
      |> \.contentInset .~ .init(leftRight: CheckoutConstants.PledgeView.Inset.leftRight)
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> checkoutSubStackViewStyle

    _ = self.applePaySectionStackView
      |> applePaySectionStackViewStyle

    _ = self.storedPaymentMethodsTitleLabel
      |> storedPaymentMethodsTitleLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadPaymentMethodsAndSelectCard
      .observeForUI()
      .observeValues { [weak self] cardValues, selectedCard in
        guard let self = self else { return }

        self.scrollView.setContentOffset(
          CGPoint(x: -CheckoutConstants.PledgeView.Inset.leftRight, y: 0),
          animated: false
        )

        self.reloadPaymentMethods(with: cardValues, andSelect: selectedCard)
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

    self.viewModel.outputs.notifyDelegateCreditCardSelected
      .observeForUI()
      .observeValues { [weak self] paymentSourceId in
        guard let self = self else { return }

        self.delegate?.pledgePaymentMethodsViewController(self, didSelectCreditCard: paymentSourceId)
      }

    self.viewModel.outputs.updateSelectedCreditCard
      .observeForUI()
      .observeValues { [weak self] card in
        self?.updateSelectedCard(to: card)
      }

    self.viewModel.outputs.goToAddCardScreen
      .observeForUI()
      .observeValues { [weak self] intent, project in
        self?.goToAddNewCard(intent: intent, project: project)
      }

    self.applePaySectionStackView.rac.hidden = self.viewModel.outputs.applePayStackViewHidden
  }

  // MARK: - Configuration

  func configure(with value: (user: User, project: Project)) {
    let pledgePaymentMethodsValue = PledgePaymentMethodsValue(
      user: value.user,
      project: value.project,
      deviceIsApplePayCapable: AppEnvironment.current.applePayCapabilities.applePayDevice()
    )

    self.viewModel.inputs.configureWith(pledgePaymentMethodsValue)
  }

  // MARK: - Actions

  @objc private func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }

  // MARK: - Functions

  private func goToAddNewCard(intent: AddNewCardIntent, project: Project) {
    let addNewCardViewController = AddNewCardViewController.instantiate()
      |> \.delegate .~ self
    addNewCardViewController.configure(with: intent, project: project)
    let navigationController = UINavigationController.init(rootViewController: addNewCardViewController)
    let offset = navigationController.navigationBar.bounds.height

    self.presentViewControllerWithSheetOverlay(navigationController, offset: offset)
  }

  private func reloadPaymentMethods(
    with cardValues: [PledgeCreditCardViewData],
    andSelect selectedCard: GraphUserCreditCard.CreditCard?
  ) {
    self.cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let cardViews = self.newCardViews(with: cardValues, selecting: selectedCard)

    let addNewCardView: PledgeAddNewCardView = PledgeAddNewCardView(frame: .zero)
      |> \.delegate .~ self

    _ = (cardViews + [addNewCardView], self.cardsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func updateSelectedCard(to card: GraphUserCreditCard.CreditCard) {
    self.cardsStackView.arrangedSubviews
      .compactMap { $0 as? PledgeCreditCardView }
      .forEach { $0.setSelectedCard(card) }
  }

  private func newCardViews(
    with cardValues: [PledgeCreditCardViewData],
    selecting selectedCard: GraphUserCreditCard.CreditCard?
  ) -> [UIView] {
    return cardValues.map { data -> PledgeCreditCardView in
      let cardView = PledgeCreditCardView(frame: .zero)
        |> \.delegate .~ self

      cardView.configureWith(value: data)

      if let selectedCard = selectedCard {
        cardView.setSelectedCard(selectedCard)
      }

      return cardView
    }
  }
}

// MARK: - Styles

private let cardsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(0)
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

private let storedPaymentMethodsTitleLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.text %~ { _ in Strings.Other_payment_methods() }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_caption1()
    |> \.textAlignment .~ .center
}

private let applePaySectionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> checkoutSubStackViewStyle
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(leftRight: Styles.grid(4))
}

// MARK: - PledgeCreditCardViewDelegate

extension PledgePaymentMethodsViewController: PledgeCreditCardViewDelegate {
  func pledgeCreditCardViewSelected(_: PledgeCreditCardView, paymentSourceId: String) {
    self.viewModel.inputs.creditCardSelected(paymentSourceId: paymentSourceId)
  }
}

// MARK: - PledgeAddNewCardViewDelegate

extension PledgePaymentMethodsViewController: PledgeAddNewCardViewDelegate {
  func pledgeAddNewCardView(_: PledgeAddNewCardView, didTapAddNewCardWith intent: AddNewCardIntent) {
    self.viewModel.inputs.addNewCardTapped(with: intent)
  }
}

// MARK: - AddNewCardViewControllerDelegate

extension PledgePaymentMethodsViewController: AddNewCardViewControllerDelegate {
  func addNewCardViewController(
    _: AddNewCardViewController,
    didAdd newCard: GraphUserCreditCard.CreditCard,
    withMessage _: String
  ) {
    self.dismiss(animated: true) {
      self.viewModel.inputs.addNewCardViewControllerDidAdd(newCard: newCard)
    }
  }

  func addNewCardViewControllerDismissed(_: AddNewCardViewController) {
    self.dismiss(animated: true)
  }
}
