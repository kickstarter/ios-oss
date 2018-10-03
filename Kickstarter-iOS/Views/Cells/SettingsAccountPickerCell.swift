import Prelude
import Library
import KsApi

internal protocol SettingsAccountPickerCellDelegate: class {
  /// Called when user did select currency in picker to update detail text in currency cell
  func currencyCellDetailTextUpdated(_ text: String)
  /// Called after user selects currency in picker to remove picker cell
  func shouldRemoveCell()
}

final class SettingsAccountPickerCell: UITableViewCell, NibLoading, ValueCell {
  internal var delegate: SettingsAccountPickerCellDelegate?
  @IBOutlet fileprivate weak var pickerView: UIPickerView!
  @IBOutlet fileprivate var lineLayer: [UIView]!

  private let viewModel: SettingsAccountPickerCellViewModelType = SettingsAccountPickerCellViewModel()

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

    self.viewModel.outputs.updateCurrencyDetailText
      .observeForUI()
      .observeValues { [weak self] text in
        self.doIfSome { $0.delegate?.currencyCellDetailTextUpdated(text) } // CHECK THIS
    }

    self.viewModel.outputs.notifyCurrencyPickerCellRemoved
      .observeForUI()
      .observeValues { [weak self] remove in
        self.doIfSome { $0.delegate?.shouldRemoveCell() }
    }
  }
}

// MARK: UIPickerViewDataSource & UIPickerViewDelegate

extension SettingsAccountPickerCell: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return Currencies.allCases.count
  }
}

extension SettingsAccountPickerCell: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Currencies(rawValue: row)?.descriptionText
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let selectedCurrency = Currencies(rawValue: row) else {
      return
    }

    self.viewModel.inputs.didSelectCurrency(currency: selectedCurrency)
  }
}
