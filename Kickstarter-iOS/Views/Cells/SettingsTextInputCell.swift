import Prelude
import UIKit

private struct Margin {
  static let leftRight: CGFloat = 8
  static let topBottom: CGFloat = 15
}

class SettingsTextInputCell: UITableViewCell {
  // MARK: - Accessors

  private lazy var stackView: UIStackView = {
    let layoutMargins = UIEdgeInsets.init(topBottom: Margin.topBottom, leftRight: Margin.leftRight)
    return UIStackView()
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ layoutMargins
      |> \.spacing .~ 8
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var label: UILabel = {
    return UILabel()
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.font .~ UIFont.preferredFont(forTextStyle: .body)
      |> \.numberOfLines .~ 0
  }()

  private lazy var textField: UITextField = {
    return UITextField()
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.font .~ UIFont.preferredFont(forTextStyle: .body)
      |> \.textAlignment .~ .right
      |> \.isSecureTextEntry .~ true
  }()

  public func configure(with title: String, placeholder: String) {
    _ = self.label
      |> \.text .~ title

    _ = self.textField
      |> \.placeholder .~ placeholder
  }

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.stackView.addArrangedSubview(self.label)
    self.stackView.addArrangedSubview(self.textField)

    self.contentView.addSubview(self.stackView)
    self.stackView.constrainEdges(to: self.contentView)
    self.stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Extensions

private extension UIView {
  func constrainEdges(to view: UIView) {
    NSLayoutConstraint.activate([
      self.topAnchor.constraint(equalTo: view.topAnchor),
      self.rightAnchor.constraint(equalTo: view.rightAnchor),
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      self.leftAnchor.constraint(equalTo: view.leftAnchor)
      ])
  }
}
