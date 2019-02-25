import KsApi
import Library
import Prelude
import UIKit

internal final class PaymentMethodsViewController: UIViewController, MessageBannerViewControllerPresenting {
  private let dataSource = PaymentMethodsDataSource()
  private let viewModel: PaymentMethodsViewModelType = PaymentMethodsViewModel()

  @IBOutlet private weak var tableView: UITableView!

  fileprivate lazy var editButton: UIBarButtonItem = {
    return UIBarButtonItem(
      title: Strings.discovery_favorite_categories_buttons_edit(),
      style: .plain,
      target: self,
      action: #selector(edit)
    )
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  public static func instantiate() -> PaymentMethodsViewController {
    return Storyboard.Settings.instantiate(PaymentMethodsViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.tableView.register(nib: .CreditCardCell)

    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self

    self.configureHeaderFooterViews()

    self.navigationItem.rightBarButtonItem = self.editButton
    self.editButton.possibleTitles = [
      Strings.discovery_favorite_categories_buttons_edit(),
      Strings.Done()
    ]

    self.dataSource.deletionHandler = { [weak self] creditCard in
      self?.viewModel.inputs.didDelete(creditCard, visibleCellCount: self?.tableView.visibleCells.count ?? 0)
    }

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in
        Strings.Payment_methods()
    }

    _ = self.tableView
      |> \.backgroundColor .~ .clear
      |> \.rowHeight .~ Styles.grid(11)
      |> \.allowsSelection .~ false
      |> \.separatorStyle .~ .singleLine
      |> \.separatorColor .~ .ksr_grey_500
      |> \.separatorInset .~ .init(left: Styles.grid(2))
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.editButton.rac.enabled = self.viewModel.outputs.editButtonIsEnabled

    self.viewModel.outputs.paymentMethods
      .observeForUI()
      .observeValues { [weak self] result in
        self?.dataSource.load(creditCards: result)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToAddCardScreen
      .observeForUI()
      .observeValues { [weak self] in
        self?.goToAddCardScreen()
    }

    self.viewModel.outputs.errorLoadingPaymentMethods
      .observeForUI()
      .observeValues { [weak self] message in
        self?.messageBannerViewController?.showBanner(with: .error, message: message)
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

    self.viewModel.outputs.editButtonTitle
      .observeForUI()
      .observeValues { [weak self] title in
        _ = self?.editButton
          ?|> \.title %~ { _ in title }
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

    self.present(nav, animated: true) { self.viewModel.inputs.addNewCardPresented() }
  }

  // MARK: - Private Helpers

  private func configureHeaderFooterViews() {
    if let header = SettingsTableViewHeader.fromNib(nib: Nib.SettingsTableViewHeader) {
      header.configure(with: Strings.Any_payment_methods_you_saved_to_Kickstarter())

      let headerContainer = UIView(frame: .zero)
      headerContainer.addSubview(header)

      self.tableView.tableHeaderView = headerContainer

      header.constrainEdges(to: headerContainer)

      _ = header.widthAnchor.constraint(equalTo: self.tableView.widthAnchor)
        |> \.priority .~ .defaultHigh
        |> \.isActive .~ true
    }

    if let footer = PaymentMethodsFooterView.fromNib(nib: Nib.PaymentMethodsFooterView) {
      footer.delegate = self

      let footerContainer = UIView(frame: .zero)
      footerContainer.addSubview(footer)

      self.tableView.tableFooterView = footerContainer

      footer.constrainEdges(to: footerContainer)

      _ = footer.widthAnchor.constraint(equalTo: self.tableView.widthAnchor)
        |> \.priority .~ .defaultHigh
        |> \.isActive .~ true
    }
  }
}

extension PaymentMethodsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.1
  }
}

extension PaymentMethodsViewController: PaymentMethodsFooterViewDelegate {
  internal func paymentMethodsFooterViewDidTapAddNewCardButton(_ footerView: PaymentMethodsFooterView) {
    self.viewModel.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()
  }
}

extension PaymentMethodsViewController: AddNewCardViewControllerDelegate {
  func addNewCardViewController(_ viewController: AddNewCardViewController,
                                didSucceedWithMessage message: String) {
    self.dismiss(animated: true) {
      self.viewModel.inputs.addNewCardSucceeded(with: message)
    }
  }

  func addNewCardViewControllerDismissed(_ viewController: AddNewCardViewController) {
    self.dismiss(animated: true) {
      self.viewModel.inputs.addNewCardDismissed()
    }
  }
}
