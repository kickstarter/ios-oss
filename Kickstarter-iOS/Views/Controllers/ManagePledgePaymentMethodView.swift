import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgePaymentMethodView: UIView {
  // MARK: - Properties

  private lazy var cardImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var cardLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var lastFourDigitsLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var paymentMethodAdaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: PledgeCreditCardViewModelType = PledgeCreditCardViewModel()

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
    self.viewModel.inputs.configureWith(value: card)
  }

  private func configureViews() {
    _ = ([self.lastFourDigitsLabel, self.expirationDateLabel], self.cardLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.cardImageView, self.cardLabelsStackView], self.paymentMethodAdaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.paymentMethodAdaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.cardImageView
      |> cardImageViewStyle

    _ = self.cardLabelsStackView
      |> verticalStackViewStyle

    _ = self.expirationDateLabel
      |> expirationDateLabelStyle

    _ = self.lastFourDigitsLabel
      |> lastFourDigitsLabelStyle

    _ = self.paymentMethodAdaptableStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> paymentMethodAdaptableStackViewStyle

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.lastFourDigitsLabel.rac.text = self.viewModel.outputs.cardNumberTextShortStyle

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

private let expirationDateLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_caption1().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
}

private let lastFourDigitsLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textColor .~ UIColor.ksr_soft_black
}

private let paymentMethodAdaptableStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Payment_method() }
    |> \.numberOfLines .~ 0
}
