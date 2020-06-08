import KsApi
import Library
import Prelude
import UIKit

protocol ManagePledgePaymentMethodViewDelegate: AnyObject {
  func managePledgePaymentMethodViewDidTapFixButton(_ view: ManagePledgePaymentMethodView)
}

final class ManagePledgePaymentMethodView: UIView {
  weak var delegate: ManagePledgePaymentMethodViewDelegate?

  // MARK: - Properties

  private lazy var cardLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var cardNumberLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var fixButton: UIButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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
      self.cardLabelsStackView,
      self.fixButton
    ], self.paymentMethodAdaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.paymentMethodAdaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.cardLabelsStackView, self.paymentMethodAdaptableStackView)
      |> ksr_setCustomSpacing(Styles.grid(6))

    self.fixButton.addTarget(
      self,
      action: #selector(ManagePledgePaymentMethodView.fixButtonTapped),
      for: .touchUpInside
    )

    self.fixButton.setContentHuggingPriority(.required, for: .horizontal)
    self.fixButton.setContentCompressionResistancePriority(.required, for: .horizontal)
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

    _ = self.fixButton
      |> redButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Fix() }
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.cardNumberLabel.rac.text = self.viewModel.outputs.cardNumberTextShortStyle
    self.cardNumberLabel.rac.accessibilityLabel = self.viewModel.outputs.cardNumberAccessibilityLabel
    self.fixButton.rac.hidden = self.viewModel.outputs.fixButtonHidden

    self.viewModel.outputs.cardImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        _ = self?.paymentMethodImageView
          ?|> \.image .~ image(named: imageName)
      }

    self.viewModel.outputs.notifyDelegateFixButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.delegate?.managePledgePaymentMethodViewDidTapFixButton(self)
      }
  }

  // MARK: - Functions

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.paymentMethodImageView.widthAnchor.constraint(
        equalToConstant: CheckoutConstants.PaymentSource.ImageView.width
      ),
      self.fixButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(10)),
      self.fixButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])
  }

  @objc private func fixButtonTapped() {
    self.viewModel.inputs.fixButtonTapped()
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
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
}

private let lastFourDigitsLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_soft_black
}

private let paymentMethodAdaptableStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}
