import KsApi
import Library
import Prelude
import UIKit

protocol PledgeCreditCardViewDelegate: AnyObject {
  func pledgeCreditCardViewSelected(
    _ pledgeCreditCardView: PledgeCreditCardView,
    paymentSourceId: String
  )
}

private enum Layout {
  enum ImageView {
    static let minWidth: CGFloat = 16.0
  }
}

final class PledgeCreditCardView: UIView {
  // MARK: - Properties

  private let adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let bottomLayoutGuide = UILayoutGuide()
  private let cardView: UIView = { UIView(frame: .zero) }()
  private let cardInfoStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let containerStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  weak var delegate: PledgeCreditCardViewDelegate?
  private let expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private let fixIconView: UIView = { UIView(frame: .zero) }()

  private let fixIconImageView: UIImageView = {
    UIImageView(image: image(named: "fix-icon", inBundle: Bundle.framework))
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let imageView: UIImageView = { UIImageView(frame: .zero) }()
  private let labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let lastFourLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let selectButton: UIButton = { UIButton(type: .custom) }()
  private let unavailableCardTypeLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel: PledgeCreditCardViewModelType = PledgeCreditCardViewModel()

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

  // MARK: - Configuration

  private func configureSubviews() {
    _ = ([self.cardView, self.unavailableCardTypeLabel], self.containerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.containerStackView, self)
      |> ksr_addSubviewToParent()

    _ = (self.fixIconImageView, self.fixIconView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.lastFourLabel, self.fixIconView], self.cardInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.cardInfoStackView, self.expirationDateLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.imageView, self.labelsStackView], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.adaptableStackView, self.selectButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.cardView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.bottomLayoutGuide, self)
      |> ksr_addLayoutGuideToView()

    self.selectButton.addTarget(
      self, action: #selector(PledgeCreditCardView.selectButtonTapped),
      for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalToConstant: CheckoutConstants.PaymentSource.Card.width),
      self.selectButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.imageView.widthAnchor.constraint(equalToConstant: CheckoutConstants.PaymentSource.ImageView.width),
      self.fixIconImageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.minWidth),
      self.fixIconImageView.heightAnchor.constraint(equalTo: self.fixIconImageView.widthAnchor),
      self.cardView.heightAnchor.constraint(
        greaterThanOrEqualToConstant:
        CheckoutConstants.CreditCardView.height
      )
    ])

    let margins = self.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.containerStackView.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.containerStackView.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.containerStackView.topAnchor.constraint(equalTo: margins.topAnchor),
      self.containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomLayoutGuide.topAnchor),
      self.bottomLayoutGuide.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.bottomLayoutGuide.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.bottomLayoutGuide.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.cardView
      |> pledgeCardViewStyle

    _ = self.containerStackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(2)

    _ = self.unavailableCardTypeLabel
      |> \.numberOfLines .~ 0
      |> \.font .~ UIFont.ksr_caption1().bolded
      |> \.textColor .~ UIColor.ksr_text_dark_grey_500
      |> \.textAlignment .~ .center

    _ = self.imageView
      |> cardImageViewStyle

    _ = self.fixIconImageView
      |> \.contentMode .~ .scaleAspectFit
      |> \.tintColor .~ .ksr_red_400

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

    _ = self.cardInfoStackView
      |> cardInfoStackViewStyle

    _ = self.rootStackView
      |> checkoutCardStackViewStyle

    _ = self.selectButton
      |> blackButtonStyle
      |> UIButton.lens.title(for: .disabled) %~ { _ in Strings.Not_available() }
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.lastFourLabel.rac.accessibilityLabel = self.viewModel.outputs.cardNumberAccessibilityLabel
    self.selectButton.rac.title = self.viewModel.outputs.selectButtonTitle
    self.selectButton.rac.selected = self.viewModel.outputs.selectButtonIsSelected
    self.selectButton.rac.enabled = self.viewModel.outputs.selectButtonEnabled
    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.lastFourLabel.rac.text = self.viewModel.outputs.cardNumberTextShortStyle
    self.unavailableCardTypeLabel.rac.hidden = self.viewModel.outputs.unavailableCardLabelHidden
    self.unavailableCardTypeLabel.rac.text = self.viewModel.outputs.unavailableCardText
    self.fixIconView.rac.hidden = self.viewModel.outputs.fixIconIsHidden

    self.viewModel.outputs.cardImage
      .observeForUI()
      .observeValues { [weak self] image in
        _ = self?.imageView
          ?|> \.image .~ image
      }

    self.viewModel.outputs.notifyDelegateOfCardSelected
      .observeForUI()
      .observeValues { [weak self] paymentSourceId in
        guard let self = self else { return }
        self.delegate?.pledgeCreditCardViewSelected(self, paymentSourceId: paymentSourceId)
      }
  }

  func configureWith(value: PledgeCreditCardViewData) {
    self.viewModel.inputs.configureWith(value: value)
  }

  // MARK: - Accessors

  func setSelectedCard(_ card: GraphUserCreditCard.CreditCard) {
    self.viewModel.inputs.setSelectedCard(card)
  }

  @objc func selectButtonTapped() {
    self.viewModel.inputs.selectButtonTapped()
  }
}

// MARK: - Styles

private let adaptableStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}

private let cardInfoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.distribution .~ .fill
    |> \.axis .~ .horizontal
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
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.gridHalf(1)
}
