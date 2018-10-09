import Prelude
import Library
import KsApi

internal protocol SettingsCurrencyPickerCellDelegate: class {
  /// Called after user selects currency in picker to remove picker cell
  func shouldDismissCurrencyPicker()
}

final class SettingsCurrencyPickerCell: UITableViewCell, NibLoading, ValueCell {
  internal var delegate: SettingsCurrencyPickerCellDelegate?
  @IBOutlet fileprivate weak var pickerView: UIPickerView!
  @IBOutlet fileprivate var lineLayer: [UIView]!

  private let viewModel: SettingsCurrencyPickerCellViewModelType = SettingsCurrencyPickerCellViewModel()

  override func awakeFromNib() {
    super.awakeFromNib()

    self.pickerView.delegate = self
    self.pickerView.dataSource = self
  }

  func configureWith(value cellValue: SettingsCellValue) {
    self.viewModel.inputs.configure(with: cellValue)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = lineLayer
      ||> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyCurrencyPickerCellRemoved
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.delegate?.shouldDismissCurrencyPicker()
    }
  }
}

// MARK: UIPickerViewDataSource & UIPickerViewDelegate

extension SettingsCurrencyPickerCell: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return Currency.allCases.count
  }
}

extension SettingsCurrencyPickerCell: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Currency(rawValue: row)?.descriptionText
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let selectedCurrency = Currency(rawValue: row) else {
      return
    }

    // swiftlint:disable:next todo
    //TODO - remove this notification once the currency can be read from the user object
    NotificationCenter.default.post(name: Notification.Name.ksr_updatedCurrencyCellDetailText,
                                    object: nil,
                                    userInfo: ["text": selectedCurrency.descriptionText]
    )

    self.viewModel.inputs.didSelectCurrency(currency: selectedCurrency)
  }
}
