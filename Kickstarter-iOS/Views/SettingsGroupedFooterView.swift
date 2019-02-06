import Prelude
import UIKit

private struct Padding {
  static let horizontal: CGFloat = 8
  static let vertical: CGFloat = 12
}

/*

 Preview

 +---------------------------------------+
 | label                                 |
 +---------------------------------------+

 */
final class SettingsGroupedFooterView: UITableViewHeaderFooterView {
  private(set) lazy var label: UILabel = {
    return UILabel(frame: .zero)
      |> \.backgroundColor .~ .groupTableViewBackground
      |> \.font .~ UIFont.preferredFont(forTextStyle: .footnote)
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    self.contentView.addSubview(self.label)

    NSLayoutConstraint.activate([
      self.label.topAnchor.constraint( equalTo: self.contentView.topAnchor, constant: Padding.vertical),
      self.label.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Padding.horizontal),
      self.label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Padding.vertical),
      self.label.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Padding.horizontal)
      ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
