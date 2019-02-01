import KsApi
import Library
import Prelude

final class SettingsCurrencyCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var chevronImageView: UIImageView!
  @IBOutlet fileprivate weak var currentCurrencyLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var stackView: UIStackView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  private let viewModel: SettingsCurrencyCellViewModelType = SettingsCurrencyCellViewModel()

  func configureWith(value: SettingsCurrencyCellValue) {
    self.viewModel.inputs.configure(with: value)

    _ = titleLabel
      |> \.text .~ value.cellType.title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsTitleLabelStyle

    _ = self.chevronImageView
      |> settingsArrowViewStyle

    _ = self.currentCurrencyLabel
      |> \.textColor .~ .ksr_text_green_700

    _ = self.separatorView
      |> separatorStyle

    _ = self.stackView
      |> \.spacing .~ Styles.grid(1)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentCurrencyLabel.rac.text = self.viewModel.outputs.chosenCurrencyText
  }
}
