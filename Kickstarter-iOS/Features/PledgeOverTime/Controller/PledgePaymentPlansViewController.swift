import Library
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

  private lazy var tableView: UITableView = { ContentSizeTableView(frame: .zero, style: .plain) }()

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
    
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    
    self.view.addSubview(self.tableView)

    self.tableView.registerCellClass(PledgePaymentPlanCell.self)
  }

  private func setupConstraints() {
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    applyWhiteBackgroundStyle(self.view)
    
    applyTableViewStyle(self.tableView)
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
    
    let selectedCellData = self.dataSource[indexPath] as! PledgePaymentPlanCellData
    
    self.viewModel.inputs.didSelectRowAtIndexPath(indexPath, with: selectedCellData)
  }
}

// MARK: Styles

private func applyTableViewStyle(_ tableView: UITableView) {
  tableView.separatorInset = .zero
  tableView.contentInsetAdjustmentBehavior = .never
  tableView.isScrollEnabled = false
  tableView.rowHeight = UITableView.automaticDimension
  
  applyWhiteBackgroundStyle(tableView)
}

private func applyWhiteBackgroundStyle(_ view: UIView) {
  view.backgroundColor = UIColor.ksr_white
}
