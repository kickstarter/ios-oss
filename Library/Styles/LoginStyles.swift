import Prelude
import Prelude_UIKit
import UIKit

public let createNewAccountButtonStyle = greenButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.Sign_up() }

public let disclaimerButtonStyle = UIButton.lens.titleColor(for: .normal) .~ .ksr_support_400
  <> UIButton.lens.titleColor(for: .highlighted) %~ { _ in
    UIColor.ksr_support_400.withAlphaComponent(0.5)
  }

  <> UIButton.lens.titleLabel.font %~~ { _, label in
    label.traitCollection.isRegularRegular ? .ksr_footnote(size: 14.0) : .ksr_footnote(size: 11.0)
  }

  <> UIButton.lens.titleLabel.textAlignment .~ .center
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.By_signing_up_you_agree_to_our_Terms_of_Use_Privacy_Policy_and_Cookie_Policy()
  }

  <> UIButton.lens.accessibilityValue %~ { _ in Strings.general_navigation_buttons_help() }
  <> UIButton.lens.accessibilityLabel %~ { _ in
    Strings.By_signing_up_you_agree_to_our_Terms_of_Use_Privacy_Policy_and_Cookie_Policy()
  }

  <> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_help_sheet() }

public let showHidePasswordButtonStyle = UIButton.lens.title(for: .normal) .~ ""
  <> UIButton.lens.tintColor .~ .ksr_support_300
  <> UIButton.lens.accessibilityLabel %~ { _ in
    Strings.Password_visibility()
  }

public let emailFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in Strings.login_placeholder_email() }
  <> UITextField.lens.keyboardType .~ .emailAddress

public func emailFieldAutoFillStyle(_ textField: UITextField) -> UITextField {
  return textField
    |> emailFieldStyle
    |> \.textContentType .~ .username
}

public let fbLoginButtonStyle = facebookButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.login_tout_buttons_log_in_with_facebook()
  }

public let fbConfirmationMessageLabelStyle = UILabel.lens.textColor .~ .ksr_support_700
  <> UILabel.lens.font .~ .ksr_body()
  <> UILabel.lens
  .text %~ { _ in Strings.By_signing_up_youll_log_in_to_Kickstarter_using_your_Facebook_account() }

public let fbConfirmEmailLabelStyle = UILabel.lens.textColor .~ .ksr_support_700
  <> UILabel.lens.font .~ .ksr_headline()
  <> UILabel.lens.textAlignment .~ .left
  <> UILabel.lens.adjustsFontSizeToFitWidth .~ true

public let fbWrongAccountLabelStyle = UILabel.lens.font .~ .ksr_caption1()
  <> UILabel.lens.textColor .~ .ksr_support_400
  <> UILabel.lens.text %~ { _ in Strings.facebook_confirmation_wrong_account_title() }

public let forgotPasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_subhead()
    <> UIButton.lens.titleColor(for: .normal) .~ .ksr_support_400
    <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_support_700
    <> UIButton.lens.title(for: .normal) %~ { _ in Strings.login_buttons_forgot_password() }

public let loginControllerStyle = UIViewController.lens.title %~ { _ in Strings.login_navbar_title() }

public let loginWithEmailButtonStyle = greyButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.login_buttons_log_in()
  }

public let newsletterSwitchStyle = UISwitch.lens.onTintColor .~ .ksr_create_700

public let passwordFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in Strings.login_placeholder_password() }
  <> UITextField.lens.secureTextEntry .~ true

public func passwordFieldAutoFillStyle(_ textField: UITextField) -> UITextField {
  return textField
    |> passwordFieldStyle
    |> \.textContentType .~ .password
}

public func newPasswordFieldAutoFillStyle(_ textField: UITextField) -> UITextField {
  let style = passwordFieldAutoFillStyle(textField)

  return style
    |> \.textContentType .~ .newPassword
}

public let resetPasswordButtonStyle = greenButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.forgot_password_buttons_reset_my_password() }

public let resetPasswordControllerStyle = UIViewController.lens.title %~ { _ in
  Strings.forgot_password_title()
}

public func applyLoginRootStackViewStyle(_ stackView: UIStackView, useLargerMargins: Bool) {
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.layoutMargins = useLargerMargins ?
    .init(topBottom: Styles.grid(5), leftRight: Styles.grid(20)) :
    .init(topBottom: Styles.grid(2), leftRight: Styles.grid(4))
}

public let signupButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in
      Strings.login_tout_default_intent_traditional_signup_button()
    }
}

public let newsletterButtonStyle = UIButton.lens.titleColor(for: .normal) .~ .ksr_support_400
  <> UIButton.lens.titleColor(for: .highlighted) %~ { _ in
    UIColor.ksr_support_400.withAlphaComponent(0.5)
  }

  <> UIButton.lens.titleLabel.font .~ .ksr_footnote()
  <> UIButton.lens.titleLabel.textAlignment .~ .left
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.Receive_a_weekly_mix_of_handpicked_projects_plus_occasional_Kickstarter_news()
  }

  <> UIButton.lens.accessibilityValue %~ { _ in Strings.general_navigation_buttons_help() }
  <> UIButton.lens.accessibilityLabel %~ { _ in
    Strings.Receive_a_weekly_mix_of_handpicked_projects_plus_occasional_Kickstarter_news()
  }

  <> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_help_sheet() }

public let signupWithEmailButtonStyle = greenButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.Sign_up() }

public let newsletterLabelStyle = UILabel.lens.font .~ .ksr_footnote()
  <> UILabel.lens.textColor .~ .ksr_support_400
  <> UILabel.lens.lineBreakMode .~ .byWordWrapping
  <> UILabel.lens.numberOfLines .~ 0
  <> UILabel.lens.text %~ { _ in
    Strings.Receive_a_weekly_mix_of_handpicked_projects_plus_occasional_Kickstarter_news()
  }

public func disclaimerAttributedString(
  with string: String,
  useLargerText: Bool
) -> NSAttributedString? {
  guard let attributedString = try? NSMutableAttributedString(
    data: Data(string.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let attributes: String.Attributes = [
    .font: useLargerText ? UIFont.ksr_footnote(size: 14.0) : .ksr_footnote(size: 11.0),
    .foregroundColor: UIColor.ksr_support_400,
    .underlineStyle: 0
  ]

  let fullRange = (attributedString.string as NSString).range(of: attributedString.string)

  attributedString.addAttributes(attributes, range: fullRange)

  return attributedString
}

public let tfaCodeFieldStyle = formFieldStyle
  <> UITextField.lens.textAlignment .~ .center
  <> UITextField.lens.font .~ .ksr_title1()
  <> UITextField.lens.keyboardType .~ .numberPad
  <> UITextField.lens.placeholder %~ { _ in Strings.two_factor_code_placeholder() }

public func tfaCodeFieldAutoFillStyle(_ textField: UITextField) -> UITextField {
  let style = textField
    |> tfaCodeFieldStyle

  return style
    |> \.textContentType .~ .oneTimeCode
}

public let twoFactorControllerStyle = UIViewController.lens.title %~ { _ in Strings.two_factor_title() }

public func applyDisclaimerTextViewStyle(_ textView: UITextView, useLargerText: Bool) {
  _ = textView
    |> tappableLinksViewStyle
  textView.attributedText =
    attributedDisclaimerText(textView: textView, useLargerText: useLargerText)
  textView.accessibilityTraits = [.staticText]
  textView.textAlignment = .center
}

public func attributedDisclaimerText(textView _: UITextView, useLargerText: Bool) -> NSAttributedString? {
  let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl

  guard let termsOfUseLink = HelpType.terms.url(withBaseUrl: baseUrl)?.absoluteString,
        let privacyPolicyLink = HelpType.privacy.url(withBaseUrl: baseUrl)?.absoluteString else { return nil }

  let string = Strings
    .By_creating_an_account_you_agree_to_Kickstarters_Terms_of_Use_and_Privacy_Policy(
      terms_of_use_link: termsOfUseLink,
      privacy_policy_link: privacyPolicyLink
    )
  return disclaimerAttributedString(with: string, useLargerText: useLargerText)
}
