import Library
import Prelude
import UIKit

// internal protocol ThanksCategoryCellDelegate: AnyObject {
//  func thanksCategoryCell(_ cell: ThanksCategoryCell, didTapSeeAllProjectsWith category: KsApi.Category)
// }

final class ViewMoreRepliesCell: UITableViewCell, ValueCell {
  // MARK: - Properties

//  internal weak var delegate: ThanksCategoryCellDelegate?

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let titleTextLabel = UILabel(frame: .zero)

  private let viewModel: ViewMoreRepliesCellViewModelType = ViewMoreRepliesCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  // TODO: - Internationalize string
  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> commentCellRootStackViewStyle
      |> \.layoutMargins .~ .init(
        top: Styles.grid(1),
        left: Styles.grid(CommentCellStyles.Layout.leftIndentWidth),
        bottom: Styles.grid(1),
        right: Styles.grid(1)
      )

    _ = self.titleTextLabel
      |> UILabel.lens.textColor .~ .ksr_create_700
      |> UILabel.lens.text .~ localizedString(key: "View more replies", defaultValue: "View more replies")
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
  }

  // MARK: - Configuration

  func configureWith(value _: Void) {
//    self.viewModel.inputs.configureWith(value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.titleTextLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}
