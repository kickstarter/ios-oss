import Library
import UIKit

internal final class SelectCurrencyCell: UITableViewCell, ValueCell {
  func configureWith(value selectedCurrencyData: SelectedCurrencyData) {
    self.textLabel?.text = selectedCurrencyData.currency.descriptionText
    self.accessoryType = selectedCurrencyData.selected ? .checkmark : .none
  }
}
