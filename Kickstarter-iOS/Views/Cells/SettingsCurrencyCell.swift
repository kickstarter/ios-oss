import KsApi
import Library
import Prelude

final class SettingsCurrencyCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var currentCurrencyLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

  private let viewModel: SettingsCurrencyCellViewModelType = SettingsCurrencyCellViewModel()

  func configureWith(value: SettingsCurrencyCellValue) {
    self.viewModel.inputs.configure(with: value)

    _ = titleLabel
      |> UILabel.lens.text .~ value.cellType.title
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
