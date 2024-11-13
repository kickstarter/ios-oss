import Library
import Prelude
import UIKit

protocol PledgePaymentPlansViewControllerDelegate: AnyObject {
  func pledgePaymentPlansViewController(
    _ viewController: PledgePaymentPlansViewController,
    didSelectPaymentPlan paymentPlan: PledgePaymentPlansType
  )
}

final class PledgePaymentPlansViewController: UIViewController {
  // MARK: Properties

  private let dataSource = PledgePaymentPlansDataSource()

  private lazy var tableView: UITableView = {
    ContentSizeTableView(frame: .zero, style: .plain)
      |> \.separatorInset .~ .zero
      |> \.contentInsetAdjustmentBehavior .~ .never
      |> \.isScrollEnabled .~ false
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.rowHeight .~ UITableView.automaticDimension
  }()

  internal weak var delegate: PledgePaymentPlansViewControllerDelegate?

  private let viewModel: PledgePaymentPlansViewModelType = PledgePaymentPlansViewModel()

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    self.tableView.registerCellClass(PledgePaymentPlanInFullCell.self)
    self.tableView.registerCellClass(PledgePaymentPlanPlotCell.self)
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

    self.viewModel.outputs.reloadPaymentPlans.observeForUI().observeValues { [weak self] data in

      guard let self = self else { return }

      self.dataSource.load(data)
      self.tableView.reloadData()
    }

    self.viewModel.outputs.notifyDelegatePaymentPlanSelected
      .observeForUI()
      .observeValues { [weak self] paymentPlan in
        guard let self = self else { return }

        self.delegate?.pledgePaymentPlansViewController(self, didSelectPaymentPlan: paymentPlan)
      }
  }

  // MARK: - Configuration

  func configure(with value: PledgePaymentPlansAndSelectionData) {
    self.viewModel.inputs.configure(with: value)
  }
}

// MARK: - UITableViewDelegate

extension PledgePaymentPlansViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.viewModel.inputs.didSelectRowAtIndexPath(indexPath)
  }
}
