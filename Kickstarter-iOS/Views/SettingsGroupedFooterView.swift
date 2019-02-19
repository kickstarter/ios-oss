import Library
import Prelude
import UIKit

final class SettingsGroupedFooterView: UITableViewHeaderFooterView {
  private(set) lazy var label: UILabel = {
    UILabel(frame: .zero)
      |> \.backgroundColor .~ .ksr_grey_200
      |> \.font .~ .ksr_footnote()
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_text_dark_grey_500
  }()

  // MARK: - Lifecycle

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    _ = self.contentView
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(1))
      |> \.preservesSuperviewLayoutMargins .~ false

    self.contentView.addSubviewConstrainedToMargins(self.label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - HeaderFooterViewProtocol

extension SettingsGroupedFooterView: HeaderFooterViewProtocol {
  func configure(withText text: String) {
    _ = self.label
      |> \.text %~ { _ in text }
  }
}
