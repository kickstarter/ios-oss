import KsApi
import Library
import Prelude
import UIKit

final class ProjectTabCheckmarkListCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = ProjectTabCheckmarkListCellViewModel()

  private lazy var categoryLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var fundingStackView: UIStackView = {
    UIStackView(frame: .zero)
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

    self.viewModel.outputs.descriptionOptionsText
      .observeForUI()
      .observeValues { [weak self] options in
        self?.fundingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        _ = options.map { [weak self] optionText in
          let imageLabelView = UIView(frame: .zero)

          let label = UILabel(frame: .zero)
            |> \.text .~ optionText
            |> optionTextLabelStyle

          let icon = UIImageView(frame: .zero)
            |> iconImageStyle

          imageLabelView.addSubview(icon)
          imageLabelView.addSubview(label)

          NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: imageLabelView.leadingAnchor),
            icon.topAnchor.constraint(equalTo: imageLabelView.topAnchor, constant: Styles.grid(1)),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: Styles.grid(2)),
            label.topAnchor.constraint(equalTo: imageLabelView.topAnchor),
            label.trailingAnchor.constraint(equalTo: imageLabelView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: imageLabelView.bottomAnchor)
          ])

          self?.fundingStackView.addArrangedSubview(imageLabelView)
        }

        self?.fundingStackView.setNeedsDisplay()
      }
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

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.fundingStackView
      |> fundingStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: ProjectTabFundingOptions) {
    self.viewModel.inputs.configureWith(value: value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.categoryLabel, self.fundingStackView], self.rootStackView)
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

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(3)
}

private let fundingStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(all: Styles.grid(1))
    |> \.spacing .~ Styles.grid(2)
}

private let iconImageStyle: ImageViewStyle = { imageView in
  imageView
    |> \.tintColor .~ LegacyColors.ksr_create_700.uiColor()
    |> \.contentMode .~ .scaleAspectFit
    |> \.image .~ Library.image(named: "checkmark")
    |> UIImageView.lens.contentHuggingPriority(for: .vertical) .~ .defaultLow
    |> UIImageView.lens.contentHuggingPriority(for: .horizontal) .~ .defaultLow
    |> UIImageView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required
    |> UIImageView.lens.contentCompressionResistancePriority(for: .horizontal) .~ .required
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let optionTextLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}
