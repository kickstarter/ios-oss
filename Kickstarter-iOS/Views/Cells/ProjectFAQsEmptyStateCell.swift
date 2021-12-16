import Library
import Prelude
import UIKit

final class ProjectFAQsEmptyStateCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var titleTextLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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
      |> \.separatorInset .~ .init(leftRight: Styles.projectPageLeftRightInset)

    _ = self.contentView
      |> \.layoutMargins .~ .init(all: Styles.projectPageLeftRightInset)

    let titleTextLabelSecondaryText = AppEnvironment.current.currentUser != nil ? Strings
      .Ask_the_project_creator_directly() : Strings.Log_in_to_ask_the_project_creator_directly()

    let titleTextLabelText = Strings
      .Looks_like_there_arent_any_frequently_asked_questions() + " " + titleTextLabelSecondaryText

    _ = self.titleTextLabel
      |> \.font .~ UIFont.ksr_body()
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_support_700
      |> \.text .~ titleTextLabelText
  }

  // MARK: - Configuration

  func configureWith(value _: Void) {
    return
  }

  private func configureViews() {
    _ = (self.titleTextLabel, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}
