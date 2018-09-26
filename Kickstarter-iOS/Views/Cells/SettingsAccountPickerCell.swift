import Prelude
import Library
import KsApi

final class SettingsAccountPickerCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var detailLabel: UILabel!
  @IBOutlet fileprivate weak var pickerView: UIPickerView!
  @IBOutlet fileprivate var lineLayer: [UIView]!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.pickerView.delegate = self
    self.pickerView.dataSource = self
  }

  func configureWith(value cellValue: SettingsCellValue) {
    let cellType = cellValue.cellType

    _ = self.titleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text .~ "Currency"

    _ = detailLabel
      |> UILabel.lens.isHidden %~ { _ in
        return cellType.hideDescriptionLabel
      }
      |> UILabel.lens.text %~ { _ in
        return cellType.description ?? ""
    }

    _ = self.pickerView
      |> UIPickerView.lens.isHidden %~ { _ in
        return cellType.hidePickerView
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = detailLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = lineLayer
      ||> separatorStyle
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
    self.detailLabel.text = Currencies(rawValue: row)?.descriptionText
  }
}
