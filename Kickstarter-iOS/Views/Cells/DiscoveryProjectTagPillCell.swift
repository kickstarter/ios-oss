import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

enum DiscoveryProjectTagPillCellType {
  case green
  case grey
}

typealias DiscoveryProjectTagPillCellValue = (type: DiscoveryProjectTagPillCellType, categoryName: String?)

final class DiscoveryProjectTagPillCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var tagIconImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var tagLabel: UILabel = { UILabel(frame: .zero) }()

  var stackViewWidthConstraint: NSLayoutConstraint?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.tagLabel
      |> tagLabelStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()
  }

  // MARK: - Configuration

  func configureWith(value: DiscoveryProjectTagPillCellValue) {
//    self.viewModel.inputs.configure(with: value)
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: .defaultHigh)

    _ = ([self.tagIconImageView, self.tagLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = [self.tagIconImageView]
      ||> \.translatesAutoresizingMaskIntoConstraints .~ false

    self.stackViewWidthConstraint = self.rootStackView.widthAnchor.constraint(equalToConstant: 0.0)
      |> \.isActive .~ true

    NSLayoutConstraint.activate([
      self.tagIconImageView.widthAnchor.constraint(equalToConstant: 13.0),
      self.tagIconImageView.heightAnchor.constraint(equalToConstant: 13.0)
    ])
  }
}

// MARK: - Styles

private let tagLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1().bolded
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.axis .~ .horizontal
    |> \.spacing .~ 0
    |> \.alignment .~ .center
    |> \.layoutMargins .~ .init(all: Styles.grid(1))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
