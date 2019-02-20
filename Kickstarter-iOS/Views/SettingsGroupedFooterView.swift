import Library
import Prelude
import UIKit

final class SettingsGroupedFooterView: UITableViewHeaderFooterView {
  // MARK: - Properties

  private(set) lazy var label: UILabel = {
    UILabel(frame: .zero)
      |> \.font %~ { _ in .ksr_footnote() }
      |> \.numberOfLines .~ 0
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

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.label
      |> \.backgroundColor .~ .ksr_grey_200
      |> \.textColor .~ .ksr_text_dark_grey_500
  }
}

// MARK: - HeaderFooterViewProtocol

extension SettingsGroupedFooterView: HeaderFooterViewProtocol {
  func configure(with text: String) {
    _ = self.label
      |> \.text %~ { _ in text }
  }
}
