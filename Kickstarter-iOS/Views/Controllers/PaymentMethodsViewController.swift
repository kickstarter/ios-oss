import KsApi
import Library
import Prelude
import UIKit

internal final class PaymentMethodsViewController: UIViewController, MessageBannerViewControllerPresenting {

  private let dataSource = PaymentMethodsDataSource()
  private let viewModel: PaymentMethodsViewModelType = PaymentMethodsViewModel()

  @IBOutlet private weak var headerLabel: UILabel!
  @IBOutlet private weak var tableView: UITableView!

  internal var messageBannerViewController: MessageBannerViewController?

  public static func instantiate() -> PaymentMethodsViewController {
    return Storyboard.Settings.instantiate(PaymentMethodsViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self
    self.tableView.register(nib: .CreditCardCell)
    self.tableView.registerHeaderFooter(nib: .PaymentMethodsFooterView)

    self.viewModel.inputs.viewDidLoad()
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: Strings.discovery_favorite_categories_buttons_edit(),
      style: .plain,
      target: self,
      action: #selector(edit)
    )

    self.dataSource.deletionHandler = { [weak self] creditCard in
      self?.viewModel.inputs.didDelete(creditCard)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
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
      |> \.rowHeight .~ Styles.grid(11)
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

    self.viewModel.outputs.presentBanner
      .observeForUI()
      .observeValues { [weak self] message in
        self?.messageBannerViewController?.showBanner(with: .success, message: message)
    }

    self.viewModel.outputs.tableViewIsEditing
      .observeForUI()
      .observeValues { [weak self] isEditing in
        self?.tableView.setEditing(isEditing, animated: true)
    }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true)
    }
  }

  // MARK: - Actions

  @objc private func edit() {
    self.viewModel.inputs.editButtonTapped()
  }

  private func goToAddCardScreen() {
    let vc = AddNewCardViewController.instantiate()
    vc.delegate = self
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

extension PaymentMethodsViewController: AddNewCardViewControllerDelegate {
  internal func presentAddCardSuccessfulBanner(_ message: String) {
    self.viewModel.inputs.cardAddedSuccessfully(message)
  }
}
