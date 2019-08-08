import KsApi
import Library
import Prelude
import UIKit

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
      self.rootStackView.widthAnchor.constraint(equalToConstant: CheckoutConstants.PaymentSource.Card.width),
      self.selectButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.imageView.widthAnchor.constraint(equalToConstant: CheckoutConstants.PaymentSource.ImageView.width)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> pledgeCardViewStyle

    _ = self.selectButton
      |> cardSelectButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Select() }

    _ = self.imageView
      |> cardImageViewStyle

    _ = self.lastFourLabel
      |> cardLastFourLabelStyle

    _ = self.expirationDateLabel
      |> cardExpirationDateLabelStyle

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
    |> \.backgroundColor .~ UIColor.white
    |> \.spacing .~ Styles.grid(2)
}

private let cardExpirationDateLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_caption2().bolded
    |> \.textColor .~ .ksr_text_dark_grey_500
}

private let cardLastFourLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_callout().bolded
    |> \.textColor .~ .ksr_soft_black
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.backgroundColor .~ UIColor.white
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.gridHalf(1)
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> checkoutStackViewStyle
    |> \.backgroundColor .~ UIColor.white
    |> \.spacing .~ Styles.grid(3)
}
