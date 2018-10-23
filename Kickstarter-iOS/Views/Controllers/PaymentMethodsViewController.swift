import KsApi
import Library
import Prelude
import UIKit

internal final class PaymentMethodsViewController: UIViewController {

  private let dataSource = PaymentMethodsDataSource()
  private let viewModel: PaymentMethodsViewModelType = PaymentMethodsViewModel()

  @IBOutlet private weak var headerLabel: UILabel!
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      self.tableView.register(nib: .CreditCardCell)
    }
  }

  public static func instantiate() -> PaymentMethodsViewController {
    return Storyboard.Settings.instantiate(PaymentMethodsViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
    self.tableView.dataSource = self.dataSource
  }

  override func bindStyles() {
    super.bindStyles()

    _ = headerLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in
        Strings.Change_payment_method()
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.didFetchPaymentMethods
      .observeForUI()
      .observeValues { [weak self] result in
        self?.dataSource.load(creditCards: result)
        self?.tableView.reloadData()
    }
  }
}
