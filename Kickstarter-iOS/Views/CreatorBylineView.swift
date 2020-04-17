import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum ImageView {
    static let minWidth: CGFloat = 36.0
  }
}

final class CreatorBylineView: UIView {
  // MARK: - Properties

  private lazy var checkmarkContainerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var creatorImageStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.axis .~ .vertical
  }()

  private lazy var creatorInfoStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var creatorImageView: CircleAvatarImageView = {
    CircleAvatarImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var creatorLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.numberOfLines .~ 0
  }()

  private lazy var creatorStatsLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.numberOfLines .~ 0
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var verifiedCheckmarkImageView: UIImageView = {
    UIImageView(image: image(named: "verified-checkmark-icon", inBundle: Bundle.framework))
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: CreatorBylineViewModelType = CreatorBylineViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.checkmarkContainerView
      |> \.backgroundColor .~ .white
      |> \.layer.cornerRadius .~ 8

    _ = self.rootStackView
      |> \.spacing .~ Styles.gridHalf(3)

    _ = self.creatorImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.creatorImageView
      |> \.clipsToBounds .~ true
      |> \.contentMode .~ .scaleAspectFit

    _ = self.verifiedCheckmarkImageView.layer
      |> \.masksToBounds .~ false

    _ = self.verifiedCheckmarkImageView
      |> \.clipsToBounds .~ true

    _ = self.creatorLabel
      |> \.textColor .~ .ksr_soft_black
      |> \.font .~ .ksr_headline(size: 13)

    _ = self.creatorStatsLabel
      |> \.textColor .~ .ksr_cobalt_500
      |> \.font .~ .ksr_headline(size: 13)
      |> \.numberOfLines .~ 0

    _ = self.creatorInfoStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText
    self.creatorStatsLabel.rac.text = self.viewModel.outputs.creatorStatsText
    self.creatorImageView.rac.ksr_imageUrl = self.viewModel.outputs.creatorImageUrl
  }

  // MARK: - Configuration

  func configureWith(project: Project, creatorDetails: ProjectCreatorDetailsEnvelope) {
    self.viewModel.inputs.configureWith(project: project, creatorDetails: creatorDetails)
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.creatorImageStackView, self.creatorInfoStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.creatorImageView, UIView()], self.creatorImageStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.checkmarkContainerView, self)
      |> ksr_addSubviewToParent()

    _ = (self.verifiedCheckmarkImageView, self.checkmarkContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.creatorLabel, self.creatorStatsLabel], self.creatorInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.creatorImageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.minWidth),
      self.creatorImageView.heightAnchor.constraint(equalTo: self.creatorImageView.widthAnchor),
      self.verifiedCheckmarkImageView.trailingAnchor.constraint(
        equalTo: self.creatorImageView.trailingAnchor, constant: Styles.gridHalf(1)
      ),
      self.verifiedCheckmarkImageView.bottomAnchor.constraint(
        equalTo: self.creatorImageView.bottomAnchor, constant: Styles.gridHalf(1)
      )
    ])
  }
}

// MARK: - Styles

private func adaptableStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : Styles.gridHalf(1))

    return stackView
      |> \.distribution .~ .fill
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.spacing .~ spacing
  }
}
