import Prelude
import Library
import KsApi

internal protocol SettingsAccountPickerCellDelegate: class {
  func currencyPickerCellExpansion(_ cell: SettingsAccountPickerCell)
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
    let cellType = cellValue.cellType

    self.viewModel.inputs.configure(with: cellValue)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = lineLayer
      ||> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyCurrencyPickerShouldCollapse
      .observeForUI()
      .observeValues { [weak self] in
        self.doIfSome { $0.delegate?.currencyPickerCellExpansion($0)}
    }

    //self.pickerView.rac.hidden = self.viewModel.outputs.currencyPickerHidden
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
   // self.detailLabel.text = Currencies(rawValue: row)?.descriptionText
  }
}
