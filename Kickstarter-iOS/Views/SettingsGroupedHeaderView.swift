import Library
import Prelude
import UIKit

final class SettingsGroupedHeaderView: UITableViewHeaderFooterView {
  private(set) lazy var label: UILabel = {
    UILabel(frame: .zero)
      |> \.backgroundColor .~ .groupTableViewBackground
      |> \.font .~ UIFont.preferredFont(forTextStyle: .footnote)
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_text_dark_grey_500
  }()

  // MARK: - Lifecycle

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    _ = self.contentView
      |> \.layoutMargins .~ .init(top: Styles.grid(5), left: Styles.grid(1), bottom: Styles.grid(2), right: Styles.grid(1))
      |> \.preservesSuperviewLayoutMargins .~ false

    self.contentView.addSubviewConstrainedToMargins(self.label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
