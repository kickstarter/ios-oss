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
  private lazy var cardsStackView: UIStackView = { UIStackView(frame: .zero) }()
  internal weak var delegate: PledgePaymentMethodsViewControllerDelegate?
  internal weak var messageDisplayingDelegate: PledgeViewControllerMessageDisplaying?
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var spacer: UIView = { UIView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
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
      .observeValues { [weak self] cardValues in
        guard let self = self else { return }
        self.scrollView.setContentOffset(.zero, animated: false)
        self.reloadPaymentMethods(with: cardValues)
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

  private func goToAddNewCard(intent: AddNewCardIntent, project: Project) {
    let addNewCardViewController = AddNewCardViewController.instantiate()
      |> \.delegate .~ self
    addNewCardViewController.configure(with: intent, project: project)
    let navigationController = UINavigationController.init(rootViewController: addNewCardViewController)
    let offset = navigationController.navigationBar.bounds.height

    self.presentViewControllerWithSheetOverlay(navigationController, offset: offset)
  }

  private func reloadPaymentMethods(with cardValues: CardViewValues) {
    self.cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let cardViews = self.newCardViews(with: cardValues)

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

  private func newCardViews(with cardValues: CardViewValues) -> [UIView] {
    let selectedCard = cardValues.cards.first
    let cards = cardValues.cards
    let availableCardTypes = cardValues.availableCardTypes

    return cards.map { card -> PledgeCreditCardView in
      let cardView = PledgeCreditCardView(frame: .zero)
        |> \.delegate .~ self

      guard let cardBrand = card.type?.rawValue else { return cardView }
      let isAvailableCardType = availableCardTypes.contains(cardBrand)

      if let selectedCard = selectedCard {
        if isAvailableCardType {
          cardView.configureWith(value: (card: card, isEnabled: true, projectCountry: nil))
          cardView.setSelectedCard(selectedCard)
        } else if !isAvailableCardType {
          cardView.configureWith(value: (
            card: card, isEnabled: false,
            projectCountry: cardValues.projectCountry
          ))
        }
      }
      return cardView
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

  private let titleLabelStyle: LabelStyle = { label in
    label
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Other_payment_methods() }
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500
      |> \.font .~ UIFont.ksr_caption1()
      |> \.textAlignment .~ .center
  }

  private let cardRestrictionLabelStyle: LabelStyle = { label in
    label
      |> \.numberOfLines .~ 0
      |> \.font .~ UIFont.ksr_caption1().bolded
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.textAlignment .~ .center
  }
}

extension PledgePaymentMethodsViewController: PledgeCreditCardViewDelegate {
  func pledgeCreditCardViewSelected(_: PledgeCreditCardView, paymentSourceId: String) {
    self.viewModel.inputs.creditCardSelected(paymentSourceId: paymentSourceId)
  }
}

extension PledgePaymentMethodsViewController: PledgeAddNewCardViewDelegate {
  func pledgeAddNewCardView(_: PledgeAddNewCardView, didTapAddNewCardWith intent: AddNewCardIntent) {
    self.viewModel.inputs.addNewCardTapped(with: intent)
  }
}

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
