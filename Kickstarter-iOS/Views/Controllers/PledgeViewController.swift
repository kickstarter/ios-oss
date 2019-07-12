import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Sheet {
    static let offset: CGFloat = 222
  }
}

final class PledgeViewController: UIViewController {
  // MARK: - Properties

  private lazy var pledgeAmountViewController = {
    PledgeAmountViewController.instantiate()
  }()

  private lazy var pledgeContinueViewController = {
    PledgeContinueViewController.instantiate()
  }()

  private lazy var pledgeDescriptionViewController = {
    PledgeDescriptionViewController.instantiate()
  }()

  private lazy var pledgeSummaryViewController = {
    PledgeSummaryViewController.instantiate()
  }()

  private lazy var pledgeShippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
  }()

  private lazy var pledgePaymentMethodsViewController = {
    PledgePaymentMethodsViewController.instantiate()
  }()

  private let viewModel: PledgeViewModelType = PledgeViewModel()


  // MARK: - Lifecycle

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project: project, reward: reward)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Back_this_project() }

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(PledgeViewController.dismissKeyboard))
    )

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureWithPledgeViewData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeDescriptionViewController.configureWith(value: data.reward)
        self?.pledgeAmountViewController.configureWith(value: (data.project, data.reward))
        self?.pledgeShippingLocationViewController.configureWith(value: (data.shipping.isLoading, data.project, data.shipping.selectedRule))
        self?.pledgeSummaryViewController.configureWith(value: (data.project, data.pledgeTotal))
        self?.pledgePaymentMethodsViewController.configureWith(value: [GraphUserCreditCard.template])
    }

    self.viewModel.outputs.presentShippingRules
      .observeForUI()
      .observeValues { [weak self] project, shippingRules, selectedShippingRule in
        self?.presentShippingRules(
          project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule
        )
      }

    self.viewModel.outputs.configureShippingLocationCellWithData
      .observeForUI()
      .observeValues { [weak self] isLoading, project, selectedShippingRule in
        self?.pledgeShippingLocationViewController.configureWith(
          value: (isLoading: isLoading, project: project, selectedShippingRule: selectedShippingRule)
        )
      }

    self.viewModel.outputs.configureSummaryCellWithData
      .observeForUI()
      .observeValues { [weak self] project, pledgeTotal in
        self?.pledgeSummaryViewController.configureWith(value: (project, pledgeTotal))
      }

    self.viewModel.outputs.dismissShippingRules
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }
  }

  // MARK: - Actions

  @objc func dismissKeyboard() {
    self.view.endEditing(true)
  }

  @objc func dismissShippingRules() {
    self.viewModel.inputs.dismissShippingRulesButtonTapped()
  }

  private func presentHelpWebViewController(with helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    let nc = UINavigationController(rootViewController: vc)
    self.present(nc, animated: true)
  }

  private func presentShippingRules(
    _ project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule
  ) {
    let vc = ShippingRulesTableViewController.instantiate()
      |> \.navigationItem.leftBarButtonItem .~ UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(PledgeViewController.dismissShippingRules)
      )
    vc.configureWith(project, shippingRules: shippingRules, selectedShippingRule: selectedShippingRule)

    let nc = UINavigationController(rootViewController: vc)
    let sheetVC = SheetOverlayViewController(child: nc, offset: Layout.Sheet.offset)
    self.present(sheetVC, animated: true)
  }
}

extension PledgeViewController: PledgeDescriptionCellDelegate {
  internal func pledgeDescriptionCellDidPresentTrustAndSafety(_: PledgeDescriptionViewController) {
    self.presentHelpWebViewController(with: .trust)
  }
}

extension PledgeViewController: PledgeAmountCellDelegate {
  func pledgeAmountCell(_: PledgeAmountViewController, didUpdateAmount amount: Double) {
    self.viewModel.inputs.pledgeAmountDidUpdate(to: amount)
  }
}

extension PledgeViewController: PledgeShippingLocationCellDelegate {
  func pledgeShippingCellWillPresentShippingRules(
    _: PledgeShippingLocationViewController,
    selectedShippingRule rule: ShippingRule
  ) {
    self.viewModel.inputs.pledgeShippingCellWillPresentShippingRules(with: rule)
  }
}

extension PledgeViewController: PledgeSummaryCellDelegate {
  internal func pledgeSummaryCell(_: PledgeSummaryViewController, didOpen helpType: HelpType) {
    self.presentHelpWebViewController(with: helpType)
  }
}
