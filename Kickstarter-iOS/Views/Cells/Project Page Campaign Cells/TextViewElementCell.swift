import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

class TextViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private var label = UILabel()

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value textElement: TextViewElement) {
    let stringText = textElement.components.reduce("") { $0 + $1.text }

    self.label.text = stringText
  }

  // MARK: View Styles

  internal override func bindStyles() {
    super.bindStyles()

    self.label.numberOfLines = 0
    self.selectionStyle = .none
  }

  // MARK: Helpers

  private func configureViews() {
    _ = (self.label, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }
}
