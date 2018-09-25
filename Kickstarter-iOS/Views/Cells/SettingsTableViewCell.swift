import Library
import Prelude
import UIKit

final class SettingsTableViewCell: UITableViewCell, ValueCell, NibLoading {


  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var detailLabel: UILabel!
  @IBOutlet fileprivate var lineLayer: [UIView]!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var pickerView: UIPickerView!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    self.pickerView.delegate = self
    self.pickerView.dataSource = self
  }

  func configureWith(value cellValue: SettingsCellValue) {
    let cellType = cellValue.cellType

    _ = titleLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text .~ cellType.title
      |> UILabel.lens.textColor .~ cellType.textColor

    _ = arrowImageView
      |> settingsArrowViewStyle
      |> UIImageView.lens.isHidden
      .~ !cellType.showArrowImageView

    _ = detailLabel
      |> UILabel.lens.isHidden %~ { _ in
        return cellType.hideDescriptionLabel
      }
      |> UILabel.lens.text %~ { _ in
        return cellType.description ?? ""
      }

    _ = pickerView
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

  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)

    let backgroundColor: UIColor = .ksr_grey_500
    let highlightedColor = highlighted ? backgroundColor.withAlphaComponent(0.1) : .white

    _ = self
      |> UITableViewCell.lens.backgroundColor .~ highlightedColor
  }
}

extension SettingsTableViewCell: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return Currencies.allCases.count
  }
}

extension SettingsTableViewCell: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return Currencies(rawValue: row)?.descriptionText
  }
}

public enum Currencies: Int {
  case euro
  case australianDollar
  case canadianDollar
  case swissFranc
  case danishKrone
  case poundSterling
  case hongKongDollar
  case yen
  case mexicanPeso
  case norwegianKrone
  case newZealandDollar
  case swedishKrona
  case singaporeDollar
  case usDollar

  public static let allCases: [Currencies] = [
  .euro,
  .australianDollar,
  .canadianDollar,
  .swissFranc,
  .danishKrone,
  .poundSterling,
  .hongKongDollar,
  .yen,
  .mexicanPeso,
  .norwegianKrone,
  .newZealandDollar,
  .swedishKrona,
  .singaporeDollar,
  .usDollar
  ]

  public static var rowHeight: CGFloat {
    return Styles.grid(7)
  }

  public var descriptionText: String {
    switch self {
    case .euro:
      return Strings.Currency_EUR()
    case .australianDollar:
      return Strings.Currency_AUD()
    case .canadianDollar:
      return Strings.Currency_CAD()
    case .swissFranc:
      return Strings.Currency_CHF()
    case .danishKrone:
      return Strings.Currency_DKK()
    case .poundSterling:
      return Strings.Currency_GBP()
    case .hongKongDollar:
      return Strings.Currency_HKD()
    case .yen:
      return Strings.Currency_JPY()
    case .mexicanPeso:
      return Strings.Currency_MXN()
    case .norwegianKrone:
      return Strings.Currency_NOK()
    case .newZealandDollar:
      return Strings.Currency_NZD()
    case .swedishKrona:
      return Strings.Currency_SEK()
    case .singaporeDollar:
      return Strings.Currency_SGD()
    case .usDollar:
      return Strings.Currency_USD()
    }
  }
}
