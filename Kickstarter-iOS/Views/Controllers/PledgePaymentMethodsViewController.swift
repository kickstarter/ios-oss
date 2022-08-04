import KsApi
import Library
import PassKit
import Prelude
import Stripe
import UIKit

protocol PledgePaymentMethodsViewControllerDelegate: AnyObject {
  func pledgePaymentMethodsViewController(
    _ viewController: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSourceId: String
  )

  func pledgePaymentMethodsViewController(
    _ viewController: PledgePaymentMethodsViewController,
    loading flag: Bool
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
      .observeValues { [weak self] cards, paymentSheetCards, selectedCard, shouldReload, isLoading in
        guard let self = self else { return }

        self.dataSource.load(
          cards,
          paymentSheetCards: paymentSheetCards,
          isLoading: isLoading
        )

        if shouldReload {
          self.tableView.reloadData()
        } else {
          guard let selectedCard = selectedCard else { return }

          self.tableView.visibleCells
            .compactMap { $0 as? PledgePaymentMethodCell }
            .forEach { $0.setSelectedCard(selectedCard) }
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
      .observeValues { [weak self] _, _ in
        /** FIXME: In https://kickstarter.atlassian.net/browse/PAY-1766 with Optimizely flags.
         self?.goToAddNewCard(intent: intent, project: project)
         */
      }

    self.viewModel.outputs.goToAddCardViaStripeScreen
      .observeForUI()
      .observeValues { [weak self] data in
        guard let strongSelf = self else { return }

        strongSelf.goToPaymentSheet(data: data)
      }

    self.viewModel.outputs.showLoadingIndicatorView
      .observeForUI()
      .observeValues { [weak self] showLoadingIndicator in
        guard let strongSelf = self else { return }

        strongSelf.delegate?.pledgePaymentMethodsViewController(strongSelf, loading: showLoadingIndicator)
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
        strongSelf.delegate?.pledgePaymentMethodsViewController(strongSelf, loading: false)

        switch result {
        case let .failure(error):
          strongSelf.messageDisplayingDelegate?
            .pledgeViewController(strongSelf, didErrorWith: error.localizedDescription)
        case let .success(paymentSheetFlowController):
          strongSelf.paymentSheetFlowController = paymentSheetFlowController
          strongSelf.paymentSheetFlowController?.presentPaymentOptions(from: strongSelf) { [weak self] in
            guard let strongSelf = self,
              let existingPaymentOption = strongSelf.paymentSheetFlowController?.paymentOption else { return }
            strongSelf.viewModel.inputs.paymentSheetDidAdd(newCard: existingPaymentOption)
          }
        }
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
    return self.viewModel.inputs.willSelectRowAtIndexPath(indexPath)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    self.viewModel.inputs.didSelectRowAtIndexPath(indexPath)
  }
}
