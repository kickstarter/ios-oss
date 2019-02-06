import Prelude
import UIKit

private struct Padding {
  static let bottom: CGFloat = 12
  static let leftRight: CGFloat = 12
  static let top: CGFloat = 30
}

/*

 Preview

 +---------------------------------------+
 | label                                 |
 +---------------------------------------+
 
 */
final class SettingsGroupedHeaderView: UITableViewHeaderFooterView {
  private(set) lazy var label: UILabel = {
    UILabel(frame: .zero)
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
      self.label.topAnchor.constraint( equalTo: self.contentView.topAnchor, constant: Padding.top),
      self.label.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -Padding.leftRight),
      self.label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Padding.bottom),
      self.label.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: Padding.leftRight)
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
