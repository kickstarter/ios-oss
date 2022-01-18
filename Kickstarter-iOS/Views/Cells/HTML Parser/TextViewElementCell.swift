import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

class TextViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var bodyLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel = TextViewElementCellViewModel()

  // MARK: Initializers

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value textElement: TextViewElement) {
    self.viewModel.inputs.configureWith(textElement: textElement)
  }

  // MARK: View Model

  internal override func bindViewModel() {
    self.bodyLabel.rac.attributedText = self.viewModel.outputs.attributedText
  }

  // MARK: View Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.bodyLabel
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.numberOfLines .~ 0
  }

  // MARK: Helpers

  private func configureViews() {
    _ = (self.bodyLabel, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}
