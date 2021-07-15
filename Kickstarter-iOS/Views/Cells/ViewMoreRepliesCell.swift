import Library
import Prelude
import UIKit

final class ViewMoreRepliesCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let titleTextLabel = UILabel(frame: .zero)

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> commentCellRootStackViewStyle
      |> \.layoutMargins .~ .init(
        top: Styles.grid(1),
        left: Styles.grid(CommentCellStyles.Content.leftIndentWidth),
        bottom: Styles.grid(1),
        right: Styles.grid(1)
      )

    _ = self.titleTextLabel
      |> \.font .~ UIFont.ksr_callout()
      |> UILabel.lens.textColor .~ .ksr_create_700
      |> UILabel.lens.text .~ Strings.View_more_replies()
  }

  // MARK: - Configuration

  func configureWith(value _: Void) {
    return
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.titleTextLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}
