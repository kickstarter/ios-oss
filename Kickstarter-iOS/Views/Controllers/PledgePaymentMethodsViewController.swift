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

  func pledgePaymentMethodsViewControllerDidTapPledgeButton(
    _ viewController: PledgePaymentMethodsViewController
  )
}

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()
  private lazy var cardsStackView: UIStackView = { UIStackView(frame: .zero) }()
  internal weak var delegate: PledgePaymentMethodsViewControllerDelegate?
  internal weak var messageDisplayingDelegate: PledgeViewControllerMessageDisplaying?
  private lazy var pledgeButton: UIButton = { UIButton.init(type: .custom) }()
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

    _ = (
      [self.applePayButton, self.spacer, self.titleLabel, self.scrollViewContainer, self.pledgeButton],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.applePayButton.addTarget(
      self,
      action: #selector(PledgePaymentMethodsViewController.applePayButtonTapped),
      for: .touchUpInside
    )

    self.pledgeButton.addTarget(
      self,
      action: #selector(PledgePaymentMethodsViewController.pledgeButtonTapped),
      for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.cardsStackView.heightAnchor.constraint(equalTo: self.scrollViewContainer.heightAnchor),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.pledgeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
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

    _ = self.pledgeButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Pledge() }

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
        guard let self = self else { return }
        self.scrollView.setContentOffset(.zero, animated: false)
        self.reloadPaymentMethods(with: cards)
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

    self.viewModel.outputs.notifyDelegatePledgeButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.delegate?.pledgePaymentMethodsViewControllerDidTapPledgeButton(self)
      }

    self.viewModel.outputs.updateSelectedCreditCard
      .observeForUI()
      .observeValues { [weak self] card in
        self?.updateSelectedCard(to: card)
      }

    self.applePayButton.rac.hidden = self.viewModel.outputs.applePayButtonHidden
    self.pledgeButton.rac.enabled = self.viewModel.outputs.pledgeButtonEnabled
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

  // MARK: - Accessors

  @objc private func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }

  @objc private func pledgeButtonTapped() {
    self.viewModel.inputs.pledgeButtonTapped()
  }

  func updatePledgeButton(_ enabled: Bool) {
    self.viewModel.inputs.updatePledgeButtonEnabled(isEnabled: enabled)
  }

  // MARK: - Functions

  private func reloadPaymentMethods(with cards: [GraphUserCreditCard.CreditCard]) {
    self.cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let cardViews = self.newCardViews(with: cards)

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
    with cards: [GraphUserCreditCard.CreditCard]
  ) -> [UIView] {
    let selectedCard = cards.first

    return cards.map { card -> PledgeCreditCardView in
      let cardView = PledgeCreditCardView(frame: .zero)
        |> \.delegate .~ self

      cardView.configureWith(value: card)

      if let selectedCard = selectedCard {
        cardView.setSelectedCard(selectedCard)
      }

      return cardView
    }
  }

  // MARK: - Styles

  private let cardsStackViewStyle: StackViewStyle = { stackView in
    stackView
      |> \.spacing .~ Styles.grid(2)
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
}

extension PledgePaymentMethodsViewController: PledgeCreditCardViewDelegate {
  func pledgeCreditCardViewSelected(_: PledgeCreditCardView, paymentSourceId: String) {
    self.viewModel.creditCardSelected(paymentSourceId: paymentSourceId)
  }
}

extension PledgePaymentMethodsViewController: PledgeAddNewCardViewDelegate {
  func pledgeAddNewCardView(_: PledgeAddNewCardView, didTapAddNewCardWith intent: AddNewCardIntent) {
    let addNewCardViewController = AddNewCardViewController.instantiate()
      |> \.delegate .~ self
    addNewCardViewController.configure(with: intent)
    let navigationController = UINavigationController.init(rootViewController: addNewCardViewController)
    let offset = navigationController.navigationBar.bounds.height

    self.presentViewControllerWithSheetOverlay(navigationController, offset: offset)
  }
}

extension PledgePaymentMethodsViewController: AddNewCardViewControllerDelegate {
  func addNewCardViewController(_: AddNewCardViewController, _ newCard: GraphUserCreditCard.CreditCard) {
    self.viewModel.inputs.addNewCardViewControllerDidAdd(newCard: newCard)
  }

  func addNewCardViewControllerDismissed(_: AddNewCardViewController) {
    self.dismiss(animated: true)
  }

  func addNewCardViewController(_: AddNewCardViewController, didSucceedWithMessage _: String) {
    self.dismiss(animated: true)
  }
}
