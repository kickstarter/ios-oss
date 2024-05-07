import KsApi
import Library
import PassKit
import Prelude
import StripePaymentSheet
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
      .observeValues { [weak self] cards, paymentSheetCards, selectedPaymentMethod, shouldReload, isLoading in
        guard let self = self else { return }

        self.dataSource.load(
          cards,
          paymentSheetCards: paymentSheetCards,
          isLoading: isLoading
        )

        if shouldReload {
          self.tableView.reloadData()
        } else {
          switch selectedPaymentMethod {
          case let .paymentIntentClientSecret(selectedPaymentSheetCardId):
            fallthrough
          case let .setupIntentClientSecret(selectedPaymentSheetCardId):
            self.tableView.visibleCells
              .compactMap { $0 as? PledgePaymentSheetPaymentMethodCell }
              .forEach { $0.setSelectedCard(selectedPaymentSheetCardId) }
          case let .savedCreditCard(selectedCardId):
            self.tableView.visibleCells
              .compactMap { $0 as? PledgePaymentMethodCell }
              .forEach { $0.setSelectedCardId(selectedCardId) }
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

  private func goToPaymentSheet(data: PaymentSheetSetupData) {
    let completion: (Result<PaymentSheet.FlowController, Error>) -> Void = { [weak self] result in
      guard let strongSelf = self else { return }

      switch result {
      case let .failure(error):
        strongSelf.viewModel.inputs.shouldCancelPaymentSheetAppearance(state: true)
        strongSelf.messageDisplayingDelegate?
          .pledgeViewController(strongSelf, didErrorWith: error.localizedDescription)
      case let .success(paymentSheetFlowController):
        let topViewController = strongSelf.navigationController?.topViewController

        assert(
          topViewController is PledgeViewController ||
            topViewController is PostCampaignCheckoutViewController,
          "PledgePaymentMethodsViewController is only intended to be presented as part of a pledge flow."
        )

        strongSelf.paymentSheetFlowController = paymentSheetFlowController
        strongSelf.paymentSheetFlowController?.presentPaymentOptions(from: strongSelf) { [weak self] in
          guard let strongSelf = self else { return }

          strongSelf.confirmPaymentResult(with: data)
        }
        strongSelf.viewModel.inputs.stripePaymentSheetDidAppear()
      }
    }

    switch data.paymentSheetType {
    case .setupIntent:
      PaymentSheet.FlowController.create(
        setupIntentClientSecret: data.clientSecret,
        configuration: data.configuration,
        completion: completion
      )
    case .paymentIntent:
      PaymentSheet.FlowController
        .create(
          paymentIntentClientSecret: data.clientSecret,
          configuration: data.configuration,
          completion: completion
        )
    }
  }

  private func confirmPaymentResult(with data: PaymentSheetSetupData) {
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
        strongSelf.didConfirmAddedPaymentOption(
          paymentOption: existingPaymentOption,
          forClientSecret: data.clientSecret,
          forPaymentSheetType: data.paymentSheetType
        )
      case .canceled:
        // User cancelled intentionally so do nothing.
        break
      case let .failed(error):
        strongSelf.messageDisplayingDelegate?
          .pledgeViewController(strongSelf, didErrorWith: error.localizedDescription)
      }
    }
  }

  private func didConfirmAddedPaymentOption(
    paymentOption: PaymentSheet.FlowController.PaymentOptionDisplayData,
    forClientSecret clientSecret: String,
    forPaymentSheetType paymentSheetType: PledgePaymentSheetType
  ) {
    // Stripe also defines this constant, but it's defined internally to the Stripe SDK :(
    let linkIdentifier = "link"

    // For regular payment types, continue with the display information they gave us
    if paymentOption.paymentMethodType != linkIdentifier {
      let paymentDisplayData = PaymentSheetPaymentOptionsDisplayData(
        image: paymentOption.image,
        label: paymentOption.label
      )

      self.viewModel.inputs.paymentSheetDidAdd(newCard: paymentDisplayData, clientSecret: clientSecret)
      return
    }

    // For link payment types, fetch the underlying payment method so we can get at the card type and label

    switch paymentSheetType {
    case .setupIntent:
      STPAPIClient.shared
        .retrieveSetupIntent(
          withClientSecret: clientSecret,
          expand: ["payment_method"]
        ) { [weak self] intent, _ in
          guard let strongSelf = self else { return }
          guard let paymentDisplayData = strongSelf.paymentDisplayData(forLink: intent?.paymentMethod)
          else { return }
          strongSelf.viewModel.inputs.paymentSheetDidAdd(
            newCard: paymentDisplayData,
            clientSecret: clientSecret
          )
        }

    case .paymentIntent:
      STPAPIClient.shared
        .retrievePaymentIntent(
          withClientSecret: clientSecret,
          expand: ["payment_method"]
        ) { [weak self] intent, _ in
          guard let strongSelf = self else { return }
          guard let paymentDisplayData = strongSelf.paymentDisplayData(forLink: intent?.paymentMethod)
          else { return }
          strongSelf.viewModel.inputs.paymentSheetDidAdd(
            newCard: paymentDisplayData,
            clientSecret: clientSecret
          )
        }
    }
  }

  private func paymentDisplayData(forLink optionalPaymentMethod: STPPaymentMethod?)
    -> PaymentSheetPaymentOptionsDisplayData? {
    guard let paymentMethod = optionalPaymentMethod else {
      return nil
    }

    let formattedLabel = self.formatLinkLabel(paymentMethod.label)
    return PaymentSheetPaymentOptionsDisplayData(
      image: paymentMethod.image,
      label: formattedLabel ?? paymentMethod.label
    )
  }

  private func formatLinkLabel(_ label: String) -> String? {
    // Link gives us a label like "Visa 1234"; reformat it to match our UI
    do {
      // Find 4 digits in the string
      let regex = try NSRegularExpression(pattern: "\\d{4}")
      let matches = regex.matches(
        in: label,
        range: NSRange(location: 0, length: label.count)
      )

      guard let match = matches.first else {
        return nil
      }

      guard let range = Range(match.range, in: label) else {
        return nil
      }

      let lastFour = label[range]
      return "•••• \(lastFour)"

    } catch {
      return nil
    }
  }

  private func updateAddNewPaymentMethodButtonLoading(state: Bool) {
    self.dataSource.updateAddNewPaymentCardLoad(state: state)

    if self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue) > 0 {
      self.tableView.reloadSections([PaymentMethodsTableViewSection.addNewCard.rawValue], with: .none)
    }
  }

  // MARK: - Public functions

  func cancelModalPresentation(_ hidden: Bool) {
    self.viewModel.inputs.shouldCancelPaymentSheetAppearance(state: hidden)
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
