import Library
import Prelude
import UIKit

final class SettingsGroupedFooterView: UITableViewHeaderFooterView {
  // MARK: - Properties

  static var defaultHeight: CGFloat = 44

  private(set) lazy var label: UILabel = {
    UILabel(frame: .zero)
      |> settingsHeaderFooterLabelBaseStyle
  }()

  // MARK: - Lifecycle

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    _ = self.contentView
      |> settingsFooterContentViewStyle

    _ = (self.label, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.label
      |> settingsHeaderFooterLabelStyle
  }
}
