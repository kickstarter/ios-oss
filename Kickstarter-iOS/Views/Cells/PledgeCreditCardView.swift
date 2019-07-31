import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Card {
    static let width: CGFloat = 240
  }

  enum ImageView {
    static let width: CGFloat = 64
    static let height: CGFloat = 40
  }

  enum Button {
    static let width: CGFloat = 217
  }
}

final class PledgeCreditCardView: UIView {
  // MARK: - Properties

  private let viewModel: CreditCardCellViewModelType = CreditCardCellViewModel()

  private let adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private let imageView: UIImageView = { UIImageView(frame: .zero) }()
  private let labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let lastFourLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let selectButton: UIButton = { UIButton(type: .custom) }()

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

  private func configureSubviews() {
    _ = self
      |> \.accessibilityElements .~ self.subviews

    _ = ([self.lastFourLabel, self.expirationDateLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.imageView, self.labelsStackView], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.adaptableStackView, self.selectButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalToConstant: Layout.Card.width),
      self.selectButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.imageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.width)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> viewStyle

    _ = self.selectButton
      |> selectButtonStyle

    _ = self.selectButton.titleLabel
      ?|> selectButtonTitleLabelStyle

    _ = self.imageView
      |> imageViewStyle

    _ = self.lastFourLabel
      |> lastFourLabelStyle

    _ = self.expirationDateLabel
      |> expirationDateLabelStyle

    _ = self.labelsStackView
      |> labelsStackViewStyle

    _ = self.adaptableStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> adaptableStackViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.lastFourLabel.rac.text = self.viewModel.outputs.cardNumberTextShortStyle
    self.viewModel.outputs.cardImage
      .observeForUI()
      .observeValues { [weak self] image in
        _ = self?.imageView
          ?|> \.image .~ image
      }
  }

  func configureWith(value: GraphUserCreditCard.CreditCard) {
    self.viewModel.inputs.configureWith(creditCard: value)
  }
}

// MARK: - Styles

private let adaptableStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}

private let expirationDateLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_caption2().bolded
    |> \.textColor .~ .ksr_text_dark_grey_500
}

private let imageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFit
}

private let lastFourLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_callout().bolded
    |> \.textColor .~ .ksr_soft_black
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.gridHalf(1)
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> checkoutStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

private let selectButtonStyle: ButtonStyle = { button in
  button
    |> checkoutSmallBlackButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Select() }
}

private let selectButtonTitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_headline()
}

private let viewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
}
