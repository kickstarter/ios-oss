import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol NoShippingPledgeViewCTAContainerViewDelegate: AnyObject {
  func applePayButtonTapped()
  func goToLoginSignup()
  func submitButtonTapped()
  func termsOfUseTapped(with helptype: HelpType)
}

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 48.0
  }
}

final class NoShippingPledgeViewCTAContainerView: UIView {
  // MARK: - Properties

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private(set) lazy var titleAndAmountStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var ctaStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var termsTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()

  private lazy var pledgeImmediatelyLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var disclaimerStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var continueButton: UIButton = {
    UIButton(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var submitButton: UIButton = {
    UIButton(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  weak var delegate: NoShippingPledgeViewCTAContainerViewDelegate?

  private let viewModel: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    PledgeViewStyles.pledgeAmountStackViewStyle(self.titleAndAmountStackView)

    PledgeViewStyles.pledgeAmountHeadingStyle(self.titleLabel)
    self.titleLabel.text = Strings.Total_amount()

    PledgeViewStyles.pledgeAmountValueStyle(self.amountLabel)

    applePayStyle(self.applePayButton)

    ctaStackViewStyle(self.ctaStackView)

    termsTextViewStyle(self.termsTextView)

    self.pledgeImmediatelyLabel.attributedText = pledgeImmediatelyText()
    self.pledgeImmediatelyLabel.numberOfLines = 0
    self.pledgeImmediatelyLabel.textAlignment = .center
    self.pledgeImmediatelyLabel.textColor = UIColor.ksr_support_400

    disclaimerStackViewStyle(self.disclaimerStackView)

    _ = self.layer
      |> layerStyle

    _ = self.continueButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }

    _ = self.submitButton
      |> greenButtonStyle

    PledgeViewStyles.rootPledgeCTAStackViewStyle(self.rootStackView)
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateToGoToLoginSignup
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.goToLoginSignup()
      }

    self.viewModel.outputs.notifyDelegateSubmitButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.submitButtonTapped()
      }

    self.viewModel.outputs.notifyDelegateApplePayButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.applePayButtonTapped()
      }

    self.viewModel.outputs.notifyDelegateOpenHelpType
      .observeForUI()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.delegate?.termsOfUseTapped(with: helpType)
      }

    self.applePayButton.rac.hidden = self.viewModel.outputs.applePayButtonIsHidden
    self.continueButton.rac.hidden = self.viewModel.outputs.continueButtonIsHidden
    self.submitButton.rac.hidden = self.viewModel.outputs.submitButtonIsHidden
    self.submitButton.rac.title = self.viewModel.outputs.submitButtonTitle
    self.submitButton.rac.enabled = self.viewModel.outputs.submitButtonIsEnabled

    self.pledgeImmediatelyLabel.rac.hidden = self.viewModel.outputs.pledgeImmediatelyLabelIsHidden
  }

  // MARK: - Configuration

  func configureWith(value: NoShippingPledgeViewCTAContainerViewData) {
    let viewModelData = PledgeViewCTAContainerViewData(
      isLoggedIn: value.isLoggedIn,
      isEnabled: value.isEnabled,
      context: value.context,
      willRetryPaymentMethod: value.willRetryPaymentMethod
    )
    self.viewModel.inputs.configureWith(value: viewModelData)

    if let attributedAmount = attributedCurrency(withProject: value.project, total: value.total) {
      self.amountLabel.attributedText = attributedAmount
    }
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.amountLabel], self.titleAndAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.continueButton, self.submitButton, self.applePayButton], self.ctaStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.pledgeImmediatelyLabel, self.termsTextView], self.disclaimerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleAndAmountStackView, self.ctaStackView, self.disclaimerStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.submitButton.addTarget(
      self, action: #selector(self.submitButtonTapped), for: .touchUpInside
    )

    self.continueButton.addTarget(
      self, action: #selector(self.continueButtonTapped), for: .touchUpInside
    )

    self.applePayButton.addTarget(
      self,
      action: #selector(self.applePayButtonTapped),
      for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.submitButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
  }

  @objc func submitButtonTapped() {
    self.viewModel.inputs.submitButtonTapped()
  }

  @objc func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }

  @objc func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }
}

extension NoShippingPledgeViewCTAContainerView: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith url: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.tapped(url)
    return false
  }
}

// MARK: - Styles

private func ctaStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.distribution = .fillEqually
  stackView.spacing = Styles.grid(2)
  stackView.layoutMargins = UIEdgeInsets.init(topBottom: Styles.grid(2), leftRight: Styles.grid(0))
  stackView.isLayoutMarginsRelativeArrangement = true
}

private func disclaimerStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(2)
  stackView.layoutMargins = UIEdgeInsets.init(
    top: Styles.grid(0),
    left: Styles.grid(5),
    bottom: Styles.grid(1),
    right: Styles.grid(5)
  )
  stackView.isLayoutMarginsRelativeArrangement = true
}

private func applePayStyle(_ button: UIButton) {
  button.clipsToBounds = true
  button.layer.masksToBounds = true
  button.layer.cornerRadius = Styles.grid(2)
  button.isAccessibilityElement = true
}

private let layerStyle: LayerStyle = { layer in
  layer
    |> checkoutLayerCardRoundedStyle
    |> \.backgroundColor .~ UIColor.ksr_white.cgColor
    |> \.shadowColor .~ UIColor.ksr_black.cgColor
    |> \.shadowOpacity .~ 0.12
    |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
    |> \.shadowRadius .~ CGFloat(1.0)
    |> \.maskedCorners .~ [
      CACornerMask.layerMaxXMinYCorner,
      CACornerMask.layerMinXMinYCorner
    ]
}

private func termsTextViewStyle(_ textView: UITextView) {
  textView.isScrollEnabled = false
  textView.isEditable = false
  textView.isUserInteractionEnabled = true
  textView.adjustsFontForContentSizeCategory = true
  textView.textContainerInset = UIEdgeInsets.zero
  textView.textContainer.lineFragmentPadding = 0
  textView.linkTextAttributes = [
    .foregroundColor: UIColor.ksr_create_700
  ]
  textView.attributedText = attributedTermsText()
  textView.accessibilityTraits = [.staticText]
  textView.textAlignment = .center
}

private func attributedTermsText() -> NSAttributedString? {
  let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl

  guard
    let termsOfUseLink = HelpType.terms.url(withBaseUrl: baseUrl)?.absoluteString,
    let privacyPolicyLink = HelpType.privacy.url(withBaseUrl: baseUrl)?.absoluteString,
    let cookiePolicyLink = HelpType.cookie.url(withBaseUrl: baseUrl)?.absoluteString
  else { return nil }

  let string = Strings.By_pledging_you_agree_to_Kickstarters_Terms_of_Use_Privacy_Policy_and_Cookie_Policy(
    terms_of_use_link: termsOfUseLink,
    privacy_policy_link: privacyPolicyLink,
    cookie_policy_link: cookiePolicyLink
  )

  return checkoutAttributedLink(with: string)
}

private func pledgeImmediatelyText() -> NSAttributedString? {
  let rawText = Strings.Your_payment_method_will_be_charged()
  return rawText.simpleHtmlAttributedString(font: UIFont.ksr_caption2())
}
