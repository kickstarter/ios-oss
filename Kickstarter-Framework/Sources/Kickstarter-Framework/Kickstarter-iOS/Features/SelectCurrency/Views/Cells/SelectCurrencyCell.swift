import Library
import UIKit

internal final class SelectCurrencyCell: UITableViewCell, ValueCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.configureStyle()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value selectedCurrencyData: SelectedCurrencyData) {
    self.textLabel?.text = selectedCurrencyData.currency.descriptionText
    self.accessoryType = selectedCurrencyData.selected ? .checkmark : .none
  }

  private func configureStyle() {
    self.textLabel?.font = UIFont.ksr_body()
  }
}
