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
          let imageLabelStackView = UIStackView(frame: .zero)
            |> imageLabelStackViewStyle

          let label = UILabel(frame: .zero)
            |> \.text .~ optionText
            |> optionTextLabelStyle

          let icon = UIImageView(frame: .zero)
            |> iconImageStyle

          imageLabelStackView.addArrangedSubview(icon)
          imageLabelStackView.addArrangedSubview(label)

          self?.fundingStackView.addArrangedSubview(imageLabelStackView)
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
    |> \.textColor .~ .ksr_support_700
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

private let imageLabelStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(all: Styles.grid(0))
    |> \.spacing .~ Styles.grid(2)
    |> \.alignment .~ .top
}

private let iconImageStyle: ImageViewStyle = { imageView in
  imageView
    |> \.tintColor .~ .ksr_create_700
    |> \.contentMode .~ .scaleAspectFit
    |> \.image .~ Library.image(named: "checkmark")
    |> UIImageView.lens.contentHuggingPriority(for: .vertical) .~ .defaultLow
    |> UIImageView.lens.contentHuggingPriority(for: .horizontal) .~ .defaultLow
    |> UIImageView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required
    |> UIImageView.lens.contentCompressionResistancePriority(for: .horizontal) .~ .required
}

private let optionTextLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
}
