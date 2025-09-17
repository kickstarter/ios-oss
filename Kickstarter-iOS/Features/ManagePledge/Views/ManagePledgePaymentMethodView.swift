import KDS
import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgePaymentMethodView: UIView {
  // MARK: - Properties

  private lazy var cardLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var cardNumberLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var expirationDateLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var paymentMethodAdaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var paymentMethodImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: ManagePledgePaymentMethodViewModelType = ManagePledgePaymentMethodViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configure(with data: ManagePledgePaymentMethodViewData) {
    self.viewModel.inputs.configureWith(data: data)
  }

  private func configureViews() {
    _ = ([self.cardNumberLabel, self.expirationDateLabel], self.cardLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([
      self.paymentMethodImageView,
      self.cardLabelsStackView
    ], self.paymentMethodAdaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.paymentMethodAdaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.cardLabelsStackView, self.paymentMethodAdaptableStackView)
      |> ksr_setCustomSpacing(Styles.grid(6))
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    _ = self.cardLabelsStackView
      |> cardLabelsStackViewStyle

    _ = self.expirationDateLabel
      |> expirationDateLabelStyle

    _ = self.cardNumberLabel
      |> lastFourDigitsLabelStyle

    _ = self.paymentMethodAdaptableStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> paymentMethodAdaptableStackViewStyle

    _ = self.paymentMethodImageView
      |> cardImageViewStyle

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Payment_method() }
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.cardNumberLabel.rac.text = self.viewModel.outputs.cardNumberTextShortStyle
    self.cardNumberLabel.rac.accessibilityLabel = self.viewModel.outputs.cardNumberAccessibilityLabel

    self.viewModel.outputs.cardImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        _ = self?.paymentMethodImageView
          ?|> \.image .~ image(named: imageName)
      }
  }

  // MARK: - Functions

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.paymentMethodImageView.widthAnchor.constraint(
        equalToConstant: CheckoutConstants.PaymentSource.ImageView.width
      )
    ])
  }
}

// MARK: - Styles

private let cardLabelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(1)
}

private let expirationDateLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_caption1().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ LegacyColors.ksr_support_400.uiColor()
}

private let lastFourDigitsLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
}

private let paymentMethodAdaptableStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}
