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
      self.tableView.registerHeaderFooter(nib: .PaymentMethodsFooterView)
    }
  }

  public static func instantiate() -> PaymentMethodsViewController {
    return Storyboard.Settings.instantiate(PaymentMethodsViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.view.backgroundColor .~ .ksr_grey_200

    _ = self.headerLabel
      |> settingsDescriptionLabelStyle
      |> \.text %~ { _ in
        Strings.Any_payment_methods_you_saved_to_Kickstarter()
    }

    _ = self.tableView
      |> \.backgroundColor .~ .clear
      |> \.separatorStyle .~ .none
      |> \.estimatedRowHeight .~ 77
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.didFetchPaymentMethods
      .observeForUI()
      .observeValues { [weak self] result in
        self?.dataSource.load(creditCards: result)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToAddCardScreen
      .observeForUI()
      .observeValues { [weak self] in
        self?.goToAddCardScreen()
    }
  }

  private func goToAddCardScreen() {
    let vc = FindFriendsViewController.configuredWith(source: .activity)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension PaymentMethodsViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 80
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footer = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: Nib.PaymentMethodsFooterView.rawValue
    ) as? PaymentMethodsFooterView
    footer?.delegate = self
    return footer
  }
}

extension PaymentMethodsViewController: PaymentMethodsFooterViewDelegate {

  internal func didTapAddNewCardButton() {
    self.viewModel.inputs.didTapAddNewCardButton()
  }
}
