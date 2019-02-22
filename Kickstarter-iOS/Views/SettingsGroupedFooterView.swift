import Library
import Prelude
import UIKit

final class SettingsGroupedFooterView: UITableViewHeaderFooterView {
  // MARK: - Properties
  
  private(set) lazy var label: UILabel = {
    UILabel(frame: .zero)
      |> settingsHeaderFooterLabelBaseStyle
  }()

  // MARK: - Lifecycle

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    _ = self.contentView
      |> settingsFooterContentViewStyle

    self.contentView.addSubviewConstrainedToMargins(self.label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.label
      |> settingsHeaderFooterLabelStyle
  }
}

// MARK: - HeaderFooterViewProtocol

extension SettingsGroupedFooterView: HeaderFooterViewProtocol {
  func configure(with text: String) {
    _ = self.label
      |> \.text .~ text
  }
}
