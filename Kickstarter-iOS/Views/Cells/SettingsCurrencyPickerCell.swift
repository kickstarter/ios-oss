import Prelude
import Library
import KsApi

internal protocol SettingsCurrencyPickerCellDelegate: class {
  func settingsCurrencyPickerCellDidChangeCurrency(_ currency: Currency)
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

  func configureWith(value cellValue: SettingsCellValue) { }

  override func bindStyles() {
    super.bindStyles()

    _ = lineLayer
      ||> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.showCurrencyChangeAlert
      .observeForUI()
      .observeValues { [weak self] currency in
        self?.delegate?.settingsCurrencyPickerCellDidChangeCurrency(currency)
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
    return Currency.allCases[row].descriptionText //Currency(rawValue: row)?.descriptionText
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let selectedCurrency = Currency.allCases[row]
    self.viewModel.inputs.didSelectCurrency(currency: selectedCurrency)
  }
}
