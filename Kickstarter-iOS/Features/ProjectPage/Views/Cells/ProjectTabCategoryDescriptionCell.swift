import KsApi
import Library
import Prelude
import UIKit

final class ProjectTabCategoryDescriptionCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = ProjectTabCategoryDescriptionCellViewModel()

  private lazy var categoryLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var descriptionLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  override func bindViewModel() {
    super.bindViewModel()

    self.categoryLabel.rac.text = self.viewModel.outputs.categoryLabelText
    self.descriptionLabel.rac.text = self.viewModel.outputs.descriptionLabelText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~ .init(leftRight: Styles.projectPageLeftRightInset)

    _ = self.contentView
      |> \.layoutMargins .~
      .init(
        topBottom: Styles.grid(2),
        leftRight: Styles.projectPageLeftRightInset
      )

    _ = self.categoryLabel
      |> categoryLabelStyle

    _ = self.descriptionLabel
      |> descriptionLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: ProjectTabCategoryDescription) {
    self.viewModel.inputs.configureWith(value: value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.categoryLabel, self.descriptionLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}

// MARK: - Styles

private let categoryLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
}

private let descriptionLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(3)
}
