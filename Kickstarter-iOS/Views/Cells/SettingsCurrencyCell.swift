import KsApi
import Library
import Prelude

final class SettingsCurrencyCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var currentCurrencyLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

  private let viewModel: SettingsCurrencyCellViewModelType = SettingsCurrencyCellViewModel()

  func configureWith(value: SettingsCellValue) {
    switch value.cellType {
    case SettingsAccountCellType.currency:
      NotificationCenter.default
        .addObserver(self,
                     selector: #selector(updateCurrencyDetailText),
                     name: .ksr_updatedCurrencyCellDetailText,
                     object: nil)
    default:
      break
    }

    self.viewModel.inputs.configure(with: value)

    _ = titleLabel
      |> UILabel.lens.text .~ value.cellType.title
  }

  @objc internal func updateCurrencyDetailText(notification: NSNotification) {
    if let currencyText = notification.userInfo?["text"] as? String {
      self.currentCurrencyLabel.text = currencyText
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsTitleLabelStyle

    _ = self.currentCurrencyLabel
      |> UILabel.lens.textColor .~ .ksr_text_green_700

    _ = self.separatorView
      |> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentCurrencyLabel.rac.text = self.viewModel.outputs.chosenCurrencyText
  }
}
