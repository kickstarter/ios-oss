import Library
import Prelude
import UIKit

final class PledgePaymentPlanInFullCell: UITableViewCell, ValueCell {
  // MARK: properties

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var titleLabel = { UILabel(frame: .zero) }()
  private lazy var checkmarkImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var selectionView: UIView = { UIView(frame: .zero) |> \.backgroundColor .~ .ksr_support_100 }()

  private let viewModel: PledgePaymentPlansCellViewModelType = PledgePaymentPlansCellViewModel()

  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()

    _ = ([self.checkmarkImageView, self.titleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_constrainViewToEdgesInParent()

    NSLayoutConstraint.activate([
      self.checkmarkImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.checkmarkImageView.heightAnchor.constraint(equalTo: self.checkmarkImageView.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectedBackgroundView .~ self.selectionView

    _ = self.rootStackView
      |> self.rootStackViewStyle

    _ = self.titleLabel
      |> self.titleLabelStyle

    _ = self.checkmarkImageView
      |> self.checkmarkImageViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.checkmarkImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        _ = self?.checkmarkImageView
          ?|> \.image .~ Library.image(named: imageName)
      }
  }

  func configureWith(value: Bool) {
    self.viewModel.inputs.configureWith(value: value)
  }

  // MARK: - Styles

  private let rootStackViewStyle: StackViewStyle = { stackView in
    stackView
      |> \.axis .~ .horizontal
      |> \.layoutMargins .~ .init(all: Styles.grid(2))
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.insetsLayoutMarginsFromSafeArea .~ false
      |> \.spacing .~ Styles.grid(2)
  }

  private let titleLabelStyle: LabelStyle = { label in
    label
      |> checkoutTitleLabelStyle
      |> \.font .~ UIFont.ksr_subhead().bolded
      |> \.text .~ "Pledge in full" // TODO: add to localizable strings. Ticket TBA
  }

  private let checkmarkImageViewStyle: ImageViewStyle = { imageView in
    imageView
      |> \.contentMode .~ .center
  }
}
