import Library
import UIKit

class TextViewElementCell: UITableViewCell, ValueCell {
  var label = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.initialize()
  }

  func initialize() {
    self.label.numberOfLines = 0
    self.addSubview(self.label)
    NSLayoutConstraint.activate([
      self.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
      self.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
      self.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 16),
      self.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
    ])
  }

  func configureWith(value: TextViewElement) {
    // TODO: Store Element to access the links
    self.label.attributedText = value.attributedText
  }

  private func getStyledComponents(bodySize _: Int, headerSize _: Int) -> NSAttributedString {
    var joinSpanned = NSAttributedString("")
  }
}
