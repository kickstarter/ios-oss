import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgePaymentMethodView: UIView {
  // MARK: - Properties

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var cardImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var cardLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var lastFourLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel = CreditCardCellViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configure(with card: GraphUserCreditCard.CreditCard) {
    self.viewModel.inputs.configureWith(creditCard: card)
  }

  private func configureViews() {
    _ = self
      |> \.accessibilityElements .~ self.subviews

    _ = ([self.lastFourLabel, self.expirationDateLabel], self.cardLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.cardImageView, self.cardLabelsStackView], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.adaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.adaptableStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> adaptableStackViewStyle

    _ = self.cardImageView
      |> cardImageViewStyle

    _ = self.cardLabelsStackView
      |> cardLabelsStackViewStyle

    _ = self.expirationDateLabel
      |> cardExpirationDateLabelStyle

    _ = self.lastFourLabel
      |> cardLastFourLabelStyle

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.lastFourLabel.rac.text = self.viewModel.outputs.cardNumberTextLongStyle
    self.viewModel.outputs.cardImage
      .observeForUI()
      .observeValues { [weak self] image in
        _ = self?.cardImageView
          ?|> \.image .~ image
      }
  }

  // MARK: - Functions

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.cardImageView.widthAnchor.constraint(
        equalToConstant: CheckoutConstants.PaymentSource.ImageView.width
      )
    ])
  }
}

// MARK: - Styles

private let adaptableStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}

private let cardExpirationDateLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_caption1().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textColor .~ .ksr_text_dark_grey_500
}

private let cardLabelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let cardLastFourLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textColor .~ .ksr_soft_black
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Payment_method() }
}
