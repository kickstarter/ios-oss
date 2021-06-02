import KsApi
import Library
import Prelude
import UIKit

final class EmptyCommentsCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var noCommentsLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.noCommentsLabel
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.font .~ UIFont.ksr_callout()
  }

  // MARK: - Configuration

  internal func configureWith(value _: Void) {
    self.noCommentsLabel.text = Strings.No_comments_yet()
  }

  private func configureViews() {
    _ = (self.noCommentsLabel, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToCenterInParent()
      |> ksr_constrainViewToEdgesInParent()
  }
}
