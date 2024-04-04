import KsApi
import Library
import PassKit
import Prelude
import UIKit

// Just a copy of PledgeViewCTAContainerView to demonstrate Dark Mode differences in SystemSettingsViewController

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 48.0
  }
}

final class DemoCTAContainerView: UIView {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var ctaStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var termsTextView: UITextView = { UITextView(frame: .zero) }()

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
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.two_factor_buttons_submit() }

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.submitButton.rac.title = self.viewModel.outputs.submitButtonTitle
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
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.submitButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
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
    |> \.backgroundColor .~ adaptiveColor(.white).cgColor
    |> \.shadowColor .~ adaptiveColor(.black).cgColor
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
    |> adaptiveTappableLinksViewStyle
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
