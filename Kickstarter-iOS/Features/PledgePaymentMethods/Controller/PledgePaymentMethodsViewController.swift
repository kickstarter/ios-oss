import KsApi
import Library
import PassKit
import Prelude
import Stripe
import UIKit

protocol PledgePaymentMethodsViewControllerDelegate: AnyObject {
  func pledgePaymentMethodsViewController(
    _ viewController: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSource: PaymentSourceSelected
  )
}

final class PledgePaymentMethodsViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = PledgePaymentMethodsDataSource()

  private lazy var tableView: UITableView = {
    ContentSizeTableView(frame: .zero, style: .plain)
      |> \.separatorInset .~ .zero
      |> \.contentInsetAdjustmentBehavior .~ .never
      |> \.isScrollEnabled .~ false
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.rowHeight .~ UITableView.automaticDimension
  }()

  internal weak var delegate: PledgePaymentMethodsViewControllerDelegate?
  internal weak var messageDisplayingDelegate: PledgeViewControllerMessageDisplaying?
  private let viewModel: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()
  private var paymentSheetFlowController: PaymentSheet.FlowController?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    self.tableView.registerCellClass(PledgePaymentMethodCell.self)
    self.tableView.registerCellClass(PledgePaymentSheetPaymentMethodCell.self)
    self.tableView.registerCellClass(PledgePaymentMethodAddCell.self)
    self.tableView.registerCellClass(PledgePaymentMethodLoadingCell.self)
  }

  private func setupConstraints() {
    _ = (self.tableView, self.view)
      |> ksr_constrainViewToEdgesInParent()
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.tableView
      |> checkoutWhiteBackgroundStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadPaymentMethods
      .observeForUI()
      .observeValues { [weak self] cards, paymentSheetCards, selectedCard, selectedPaymentSheetCardId, shouldReload, isLoading in
        guard let self = self else { return }

        self.dataSource.load(
          cards,
          paymentSheetCards: paymentSheetCards,
          isLoading: isLoading
        )

        if shouldReload {
          self.tableView.reloadData()
        } else {
          switch (selectedCard, selectedPaymentSheetCardId) {
          case let (.none, .some(selectedPaymentSheetCardId)):
            self.tableView.visibleCells
              .compactMap { $0 as? PledgePaymentSheetPaymentMethodCell }
              .forEach { $0.setSelectedCard(selectedPaymentSheetCardId) }
          case let (.some(selectedCard), .none):
            self.tableView.visibleCells
              .compactMap { $0 as? PledgePaymentMethodCell }
              .forEach { $0.setSelectedCard(selectedCard) }
          default:
            break
          }
        }
      }

    self.viewModel.outputs.notifyDelegateLoadPaymentMethodsError
      .observeForUI()
      .observeValues { [weak self] errorMessage in
        guard let self = self else { return }
        self.messageDisplayingDelegate?.pledgeViewController(self, didErrorWith: errorMessage)
      }

    self.viewModel.outputs.notifyDelegateCreditCardSelected
      .observeForUI()
      .observeValues { [weak self] paymentSourceId in
        guard let self = self else { return }

        self.delegate?.pledgePaymentMethodsViewController(self, didSelectCreditCard: paymentSourceId)
      }

    self.viewModel.outputs.goToAddCardScreen
      .observeForUI()
      .observeValues { [weak self] intent, project in
        self?.goToAddNewCard(intent: intent, project: project)
      }

    self.viewModel.outputs.goToAddCardViaStripeScreen
      .observeForUI()
      .observeValues { [weak self] data in
        guard let strongSelf = self else { return }

        strongSelf.goToPaymentSheet(data: data)
      }

    self.viewModel.outputs.updateAddNewCardLoading
      .observeForUI()
      .observeValues { [weak self] showLoadingIndicator in
        guard let strongSelf = self else { return }

        strongSelf.updateAddNewPaymentMethodButtonLoading(state: showLoadingIndicator)
      }
  }

  // MARK: - Configuration

  func configure(with value: PledgePaymentMethodsValue) {
    self.viewModel.inputs.configure(with: value)
  }

  // MARK: - Functions

  private func goToAddNewCard(intent: AddNewCardIntent, project: Project) {
    let addNewCardViewController = AddNewCardViewController.instantiate()
      |> \.delegate .~ self
    addNewCardViewController.configure(with: intent, project: project)
    let navigationController = UINavigationController.init(rootViewController: addNewCardViewController)

    self.present(navigationController, animated: true)
  }

  private func goToPaymentSheet(data: PaymentSheetSetupData) {
    PaymentSheet.FlowController
      .create(
        setupIntentClientSecret: data.clientSecret,
        configuration: data.configuration
      ) { [weak self] result in
        guard let strongSelf = self else { return }

        switch result {
        case let .failure(error):
          strongSelf.viewModel.inputs.shouldCancelPaymentSheetAppearance(state: true)
          strongSelf.messageDisplayingDelegate?
            .pledgeViewController(strongSelf, didErrorWith: error.localizedDescription)
        case let .success(paymentSheetFlowController):
          let topViewController = strongSelf.navigationController?.topViewController
          let paymentSheetShownWithinPledgeContext = topViewController is PledgeViewController

          if paymentSheetShownWithinPledgeContext {
            strongSelf.paymentSheetFlowController = paymentSheetFlowController
            strongSelf.paymentSheetFlowController?.presentPaymentOptions(from: strongSelf) { [weak self] in
              guard let strongSelf = self else { return }

              strongSelf.confirmPaymentResult(with: data.clientSecret)
            }
          }
        }
      }
  }

  private func confirmPaymentResult(with clientSecret: String) {
    guard self.paymentSheetFlowController?.paymentOption != nil else {
      self.viewModel.inputs.shouldCancelPaymentSheetAppearance(state: true)

      return
    }

    self.paymentSheetFlowController?.confirm(from: self) { [weak self] paymentResult in

      guard let strongSelf = self else { return }

      strongSelf.viewModel.inputs.shouldCancelPaymentSheetAppearance(state: true)

      guard let existingPaymentOption = strongSelf.paymentSheetFlowController?.paymentOption else { return }

      switch paymentResult {
      case .completed:
        strongSelf.viewModel.inputs
          .paymentSheetDidAdd(newCard: existingPaymentOption, setupIntent: clientSecret)
      case .canceled:
        strongSelf.messageDisplayingDelegate?
          .pledgeViewController(strongSelf, didErrorWith: Strings.general_error_something_wrong())
      case let .failed(error):
        strongSelf.messageDisplayingDelegate?
          .pledgeViewController(strongSelf, didErrorWith: error.localizedDescription)
      }
    }
  }

  private func updateAddNewPaymentMethodButtonLoading(state: Bool) {
    self.dataSource.updateAddNewPaymentCardLoad(state: state)

    if self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue) > 0 {
      self.tableView.reloadSections([PaymentMethodsTableViewSection.addNewCard.rawValue], with: .none)
    }
  }
}

// MARK: - AddNewCardViewControllerDelegate

extension PledgePaymentMethodsViewController: AddNewCardViewControllerDelegate {
  func addNewCardViewController(
    _: AddNewCardViewController,
    didAdd newCard: UserCreditCards.CreditCard,
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

// MARK: - UITableViewDelegate

extension PledgePaymentMethodsViewController: UITableViewDelegate {
  func tableView(_: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    guard !self.dataSource.isLoadingStateCell(indexPath: indexPath) else {
      return nil
    }
    return self.viewModel.inputs.willSelectRowAtIndexPath(indexPath)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    self.viewModel.inputs.didSelectRowAtIndexPath(indexPath)
  }
}

// MARK: - PaymentSheetAppearanceDelegate

extension PledgePaymentMethodsViewController: PaymentSheetAppearanceDelegate {
  func pledgeViewControllerPaymentSheet(_: PledgeViewController, hidden: Bool) {
    self.viewModel.inputs.shouldCancelPaymentSheetAppearance(state: hidden)
  }
}
