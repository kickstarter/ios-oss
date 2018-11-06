import KsApi
import Library
import Prelude
import UIKit

internal final class PaymentMethodsViewController: UIViewController {

  private let dataSource = PaymentMethodsDataSource()
  private let viewModel: PaymentMethodsViewModelType = PaymentMethodsViewModel()

  @IBOutlet private weak var headerLabel: UILabel!
  @IBOutlet private weak var tableView: UITableView!

  public static func instantiate() -> PaymentMethodsViewController {
    return Storyboard.Settings.instantiate(PaymentMethodsViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.register(nib: .CreditCardCell)
    self.tableView.registerHeaderFooter(nib: .PaymentMethodsFooterView)

    self.viewModel.inputs.viewDidLoad()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: Strings.discovery_favorite_categories_buttons_edit(),
      style: .plain,
      target: self,
      action: nil
    )
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in
        Strings.Payment_methods()
    }

    _ = self.headerLabel
      |> settingsDescriptionLabelStyle
      |> \.text %~ { _ in
        Strings.Any_payment_methods_you_saved_to_Kickstarter()
    }

    _ = self.tableView
      |> \.backgroundColor .~ .clear
      |> \.estimatedRowHeight .~ Styles.grid(13)
      |> \.allowsSelection .~ false
      |> \.separatorStyle .~ .none
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.paymentMethods
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
    let vc = AddNewCardViewController.instantiate()
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}

extension PaymentMethodsViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return Styles.grid(13)
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

  internal func paymentMethodsFooterViewDidTapAddNewCardButton(_ footerView: PaymentMethodsFooterView) {
    self.viewModel.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()
  }
}
