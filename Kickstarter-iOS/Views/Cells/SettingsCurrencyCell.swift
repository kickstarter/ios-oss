import Prelude
import Library
import KsApi

final class SettingsCurrencyCell: UITableViewCell, NibLoading, ValueCell {
  fileprivate let viewModel = SettingsCurrencyCellViewModel()

  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var currentCurrencyLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

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

    _ = titleLabel
      |> UILabel.lens.text .~ value.cellType.title

    _ = currentCurrencyLabel
      |> UILabel.lens.textColor .~ value.cellType.detailTextColor
      |> UILabel.lens.text %~ { _ in value.cellType.description ?? "" }
  }

  @objc internal func updateCurrencyDetailText(notification: NSNotification) {
    if let currencyText = notification.userInfo?["text"] as? String {
      self.currentCurrencyLabel.text = currencyText
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
      |> settingsTitleLabelStyle

    _ = separatorView
      |> separatorStyle
  }
}
