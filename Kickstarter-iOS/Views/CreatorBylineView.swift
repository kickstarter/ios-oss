import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum ImageView {
    static let minHeight: CGFloat = 36.0
    static let minWidth: CGFloat = 36.0
  }
}

final class CreatorByLineView: UIView {
  // MARK: - Properties

  private lazy var creatorInfoStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var creatorImageView: CircleAvatarImageView = {
  CircleAvatarImageView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false }()

  private lazy var creatorLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var creatorStatsLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var verifiedCheckmarkImageView: UIImageView = {
    UIImageView(image: image(named: "verified-checkmark-icon", inBundle: Bundle.framework))
       |> \.translatesAutoresizingMaskIntoConstraints .~ false }()

  private let viewModel: CreatorByLineViewViewModelType = CreatorByLineViewViewModel()

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

     _ = self.creatorImageView
       |> ignoresInvertColorsImageViewStyle

     _ = self.creatorImageView
      |> UIImageView.lens.clipsToBounds .~ true
      |> UIImageView.lens.contentMode .~ .scaleAspectFit

     _ = self.verifiedCheckmarkImageView.layer
       |> \.masksToBounds .~ false

     _ = self.verifiedCheckmarkImageView
       |> UIImageView.lens.clipsToBounds .~ true
       |> UIImageView.lens.contentMode .~ .scaleToFill

     _ = self.creatorLabel
       |> UILabel.lens.textColor .~ .ksr_soft_black
       |> UILabel.lens.font .~ .ksr_headline(size: 13)

     _ = self.creatorStatsLabel
       |> UILabel.lens.textColor .~ .ksr_blue_500
       |> UILabel.lens.font .~ .ksr_headline(size: 13)
       |> \.text %~ { _ in "First-time creator • 12 projects backed" }

     _ = self.creatorInfoStackView
       |> adaptableStackViewStyle(isAccessibilityCategory)
   }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.creatorLabel.rac.text = self.viewModel.outputs.creatorLabelText
    self.creatorImageView.rac.imageUrl = self.viewModel.outputs.creatorImageUrl
  }

  // MARK: - Configuration

  func configureWith(value project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.creatorInfoStackView, self)
      |> ksr_addSubviewToParent()

    _ = (self.creatorImageView, self)
      |> ksr_addSubviewToParent()

    _ = (self.verifiedCheckmarkImageView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.creatorLabel, self.creatorStatsLabel], self.creatorInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.creatorImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Styles.grid(3)),
      self.creatorImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      self.creatorInfoStackView.topAnchor.constraint(equalTo: self.topAnchor),
      self.creatorInfoStackView.leadingAnchor.constraint(equalTo: self.creatorImageView.trailingAnchor,
                                                         constant: Styles.gridHalf(2)),
      self.creatorInfoStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.creatorInfoStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.creatorImageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.minWidth),
      self.creatorImageView.heightAnchor.constraint(equalToConstant: Layout.ImageView.minHeight),
      self.creatorImageView.bottomAnchor.constraint(equalTo: self.verifiedCheckmarkImageView.bottomAnchor),
      self.creatorImageView.trailingAnchor.constraint(
        equalTo: self.verifiedCheckmarkImageView.trailingAnchor, constant: 1.0)
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
