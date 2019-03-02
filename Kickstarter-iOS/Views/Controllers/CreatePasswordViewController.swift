import Library
import Prelude
import Result
import ReactiveSwift
import UIKit

enum CreatePasswordRow: CaseIterable {
  case newPassword
  case confirmNewPassword
}

extension CreatePasswordRow {
  var placeholder: String {
    return Strings.signup_input_fields_password()
  }

  var returnKeyType: UIReturnKeyType {
    switch self {
    case .newPassword: return .next
    case .confirmNewPassword: return .done
    }
  }

  var title: String {
    switch self {
    case .newPassword: return Strings.New_password()
    case .confirmNewPassword: return Strings.Confirm_password()
    }
  }
}

@objc protocol CreatePasswordViewControllerType {
  @objc optional func newPasswordTextFieldChanged(_ sender: UITextField)
  @objc optional func newPasswordTextFieldDidReturn(_ sender: UITextField)
  @objc optional func newPasswordConfirmationTextFieldChanged(_ sender: UITextField)
  @objc optional func newPasswordConfirmationTextFieldDidReturn(_ sender: UITextField)
}

final class CreatePasswordViewController: UITableViewController {
  // MARK: - Properties

  private let viewModel: CreatePasswordViewModelType = CreatePasswordViewModel()
  private weak var newPasswordTextField: UITextField?
  private weak var newPasswordConfirmationTextField: UITextField?
  private weak var footerView: SettingsGroupedFooterView?

  private lazy var rightBarButtonItem: UIBarButtonItem = {
    UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
      |> \.isEnabled .~ false
  }()

  // MARK: - Lifecycle

  static func instantiate() -> CreatePasswordViewController {
    return CreatePasswordViewController(style: .grouped)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Create_password() }

    _ = self.navigationItem
      |> \.rightBarButtonItem .~ self.rightBarButtonItem

    self.tableView.registerHeaderFooterClass(SettingsGroupedHeaderView.self)
    self.tableView.registerHeaderFooterClass(SettingsGroupedFooterView.self)
    self.tableView.registerCellClass(SettingsTextInputCell.self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> settingsGroupedTableViewStyle
      |> \.allowsSelection .~ true
  }

  // MARK: - Binding

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.newPasswordConfirmationTextFieldBecomeFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.newPasswordConfirmationTextField?.becomeFirstResponder()
    }

    self.viewModel.outputs.newPasswordConfirmationTextFieldResignFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.newPasswordConfirmationTextField?.resignFirstResponder()
    }

    self.viewModel.outputs.validationLabelIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.footerView?.isHidden = isHidden
    }

    self.viewModel.outputs.validationLabelText
      .observeForUI()
      .observeValues { [weak self] text in
        UIView.performWithoutAnimation {
          self?.tableView.beginUpdates()
          self?.footerView?.configure(with: text)
          self?.tableView.endUpdates()
        }
    }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
  }

  func bind(cell: UITableViewCell, for row: CreatePasswordRow) {
    guard let textInputCell = cell as? SettingsTextInputCell else { return }

    switch row {
    case .newPassword:
      self.newPasswordTextField = textInputCell.textField
    case .confirmNewPassword:
      self.newPasswordConfirmationTextField = textInputCell.textField
    }
  }

  func bind(footerView: UIView) {
    guard let groupedFooterView = footerView as? SettingsGroupedFooterView else { return }

    self.footerView = groupedFooterView
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CreatePasswordRow.allCases.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SettingsTextInputCell.self, for: indexPath)

    guard let textInputCell = cell as? SettingsTextInputCell else { return cell }

    let row = CreatePasswordRow.allCases[indexPath.row]

    textInputCell.configure(with: row.placeholder, returnKeyType: row.returnKeyType, title: row.title)
    textInputCell.configure(with: textFieldTargetActions(for: self, row: row))

    return textInputCell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let textInputCell = tableView.cellForRow(at: indexPath) as? SettingsTextInputCell else { return }

    textInputCell.textField.becomeFirstResponder()
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let className = SettingsGroupedHeaderView.self

    guard let headerView = tableView.dequeueReusableHeaderFooterView(withClass: className)
      as? SettingsGroupedHeaderView else { return nil }

    headerView.configure(
      with: Strings.Well_ask_you_to_sign_back_into_the_Kickstarter_app_once_youve_changed_your_password()
    )

    return headerView
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let className = SettingsGroupedFooterView.self
    guard let footerView = tableView.dequeueReusableHeaderFooterView(withClass: className)
      as? SettingsGroupedFooterView else { return nil }

    footerView.configure(with: self.viewModel.outputs.currentValidationLabelText())

    return footerView
  }

  // swiftlint:disable line_length
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.bind(cell: cell, for: CreatePasswordRow.allCases[indexPath.row])
  }

  override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    self.bind(footerView: view)
  }
  // swiftlint:enable line_length
}

extension CreatePasswordViewController: CreatePasswordViewControllerType {
  @objc func newPasswordTextFieldChanged(_ sender: UITextField) {
    self.viewModel.inputs.newPasswordTextFieldChanged(text: sender.text)
  }

  @objc func newPasswordTextFieldDidReturn(_ sender: UITextField) {
    self.viewModel.inputs.newPasswordTextFieldDidReturn()
  }

  @objc func newPasswordConfirmationTextFieldChanged(_ sender: UITextField) {
    self.viewModel.inputs.newPasswordConfirmationTextFieldChanged(text: sender.text)
  }

  @objc func newPasswordConfirmationTextFieldDidReturn(_ sender: UITextField) {
    self.viewModel.inputs.newPasswordConfirmationTextFieldDidReturn()
  }
}

// swiftlint:disable line_length
func textFieldTargetActions(for controller: CreatePasswordViewControllerType, row: CreatePasswordRow) -> [TextFieldTargetAction] {
  let changedSelector: Selector
  let didReturnSelector: Selector

  switch row {
  case .newPassword:
    changedSelector = #selector(controller.newPasswordTextFieldChanged(_:))
    didReturnSelector = #selector(controller.newPasswordTextFieldDidReturn(_:))
  case .confirmNewPassword:
    changedSelector = #selector(controller.newPasswordConfirmationTextFieldChanged(_:))
    didReturnSelector = #selector(controller.newPasswordConfirmationTextFieldDidReturn(_:))
  }

  return [
    (controller.self, changedSelector, .editingChanged),
    (controller.self, didReturnSelector, .editingDidEndOnExit)
  ]
}
// swiftlint:enable line_length
