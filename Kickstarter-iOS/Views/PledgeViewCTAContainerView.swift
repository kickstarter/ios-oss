import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol PledgeViewCTAContainerViewDelegate: AnyObject {
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

final class PledgeViewCTAContainerView: UIView {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var ctaStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var termsTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()

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

  weak var delegate: PledgeViewCTAContainerViewDelegate?

  private let viewModel: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()

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

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.applePayButton
      |> applePayButtonStyle

    _ = self.ctaStackView
      |> ctaStackViewStyle

    _ = self.termsTextView
      |> termsTextViewStyle

    _ = self.disclaimerStackView
      |> disclaimerStackViewStyle

    _ = self.layer
      |> layerStyle

    _ = self.continueButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }

    _ = self.submitButton
      |> greenButtonStyle

    _ = self.rootStackView
      |> rootStackViewStyle
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
  }

  // MARK: - Configuration

  func configureWith(value: PledgeViewCTAContainerViewData) {
    self.viewModel.inputs.configureWith(value: value)
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.continueButton, self.submitButton, self.applePayButton], self.ctaStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.termsTextView], self.disclaimerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.ctaStackView, self.disclaimerStackView], self.rootStackView)
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

extension PledgeViewCTAContainerView: UITextViewDelegate {
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

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(
      top: Styles.grid(2),
      left: Styles.grid(3),
      bottom: Styles.grid(0),
      right: Styles.grid(3)
    )
    |> \.spacing .~ Styles.grid(1)
}

private let disclaimerLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_footnote()
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.text %~ { _ in
      "By pledging you agree to Kickstarter's Terms of Use, Privacy Policy and Cookie Policy"
    }
}

private let ctaStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fillEqually
    |> \.spacing .~ Styles.grid(2)
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(2), leftRight: Styles.grid(0))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let disclaimerStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.layoutMargins .~ UIEdgeInsets.init(
      top: Styles.grid(0),
      left: Styles.grid(5),
      bottom: Styles.grid(1),
      right: Styles.grid(5)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let layerStyle: LayerStyle = { layer in
  layer
    |> checkoutLayerCardRoundedStyle
    |> \.backgroundColor .~ UIColor.white.cgColor
    |> \.shadowColor .~ UIColor.black.cgColor
    |> \.shadowOpacity .~ 0.12
    |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
    |> \.shadowRadius .~ CGFloat(1.0)
    |> \.maskedCorners .~ [
      CACornerMask.layerMaxXMinYCorner,
      CACornerMask.layerMinXMinYCorner
    ]
}

private let termsTextViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  _ = textView
    |> tappableLinksViewStyle
    |> \.attributedText .~ attributedTermsText()
    |> \.accessibilityTraits .~ [.staticText]
    |> \.textAlignment .~ .center

  return textView
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
