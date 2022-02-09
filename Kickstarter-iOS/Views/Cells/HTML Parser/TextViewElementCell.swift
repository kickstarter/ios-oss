import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

class TextViewElementCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private lazy var textView: UITextView = { UITextView(frame: .zero) }()
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
    self.viewModel.outputs.attributedText
      .observeForUI()
      .observeValues { [weak self] attributedText in
        self?.textView.attributedText = attributedText
      }
  }

  // MARK: View Styles

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~
      .init(
        top: 0,
        left: 0,
        bottom: 0,
        right: self.bounds.size.width + ProjectHeaderCellStyles.Layout.insets
      )

    _ = self.contentView
      |> \.layoutMargins .~ .init(
        topBottom: Styles.gridHalf(3),
        leftRight: Styles.grid(3)
      )

    _ = self.textView
      |> textViewStyle
  }

  // MARK: Helpers

  private func configureViews() {
    _ = (self.textView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}
