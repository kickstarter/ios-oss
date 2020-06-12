import Prelude
import Prelude_UIKit
import UIKit

public let createNewAccountButtonStyle = greenButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.facebook_confirmation_button() }

public let disclaimerButtonStyle = UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_400
  <> UIButton.lens.titleColor(for: .highlighted) %~ { _ in
    UIColor.ksr_text_dark_grey_400.withAlphaComponent(0.5)
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
  <> UIButton.lens.tintColor .~ .ksr_grey_400
  <> UIButton.lens.accessibilityLabel %~ { _ in
    Strings.Password_visibility()
  }

public let fbDisclaimerTextStyle = UILabel.lens.font %~~ { _, label in
  label.traitCollection.isRegularRegular ? .ksr_footnote(size: 14.0) : .ksr_footnote(size: 11.0)
}

  <> UILabel.lens.backgroundColor .~ .white
  <> UILabel.lens.lineBreakMode .~ .byWordWrapping
  <> UILabel.lens.numberOfLines .~ 0
  <> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
  <> UILabel.lens.textAlignment .~ .center
  <> UILabel.lens.text %~ { _ in
    Strings.Well_import_your_name_and_profile_photo_and_access_your_friend_list()
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

public let fbConfirmationMessageLabelStyle = UILabel.lens.textColor .~ .ksr_soft_black
  <> UILabel.lens.font .~ .ksr_body()
  <> UILabel.lens.text %~ { _ in Strings.Youre_about_to_create_a_new_Kickstarter_account() }

public let fbConfirmEmailLabelStyle = UILabel.lens.textColor .~ .ksr_soft_black
  <> UILabel.lens.font .~ .ksr_headline()
  <> UILabel.lens.textAlignment .~ .left
  <> UILabel.lens.adjustsFontSizeToFitWidth .~ true

public let fbWrongAccountLabelStyle = UILabel.lens.font .~ .ksr_caption1()
  <> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
  <> UILabel.lens.text %~ { _ in Strings.facebook_confirmation_wrong_account_title() }

public let forgotPasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_subhead()
    <> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
    <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_soft_black
    <> UIButton.lens.title(for: .normal) %~ { _ in Strings.login_buttons_forgot_password() }

public let loginControllerStyle = UIViewController.lens.title %~ { _ in Strings.login_navbar_title() }

public let loginWithEmailButtonStyle = greyButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.login_buttons_log_in_email() }

public let newsletterSwitchStyle = UISwitch.lens.onTintColor .~ .ksr_green_700

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

  if #available(iOS 12, *) {
    return style
      |> \.textContentType .~ .newPassword
  }
  return style
}

public let resetPasswordButtonStyle = greenButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.forgot_password_buttons_reset_my_password() }

public let resetPasswordControllerStyle = UIViewController.lens.title %~ { _ in
  Strings.forgot_password_title()
}

public let loginRootStackViewStyle =
  UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.layoutMargins %~~ { _, stack in
      stack.traitCollection.isRegularRegular
        ? .init(topBottom: Styles.grid(10), leftRight: Styles.grid(20))
        : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(4))
    }

public let signupButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in
      Strings.login_tout_default_intent_traditional_signup_button()
    }
}

public let signupControllerStyle = UIViewController.lens.title %~ { _ in Strings.signup_button() }

public let newsletterButtonStyle = UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
  <> UIButton.lens.titleColor(for: .highlighted) %~ { _ in
    UIColor.ksr_text_dark_grey_500.withAlphaComponent(0.5)
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
  <> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
  <> UILabel.lens.lineBreakMode .~ .byWordWrapping
  <> UILabel.lens.numberOfLines .~ 0
  <> UILabel.lens.text %~ { _ in
    Strings.Receive_a_weekly_mix_of_handpicked_projects_plus_occasional_Kickstarter_news()
  }

public let tfaCodeFieldStyle = formFieldStyle
  <> UITextField.lens.textAlignment .~ .center
  <> UITextField.lens.font .~ .ksr_title1()
  <> UITextField.lens.keyboardType .~ .numberPad
  <> UITextField.lens.placeholder %~ { _ in Strings.two_factor_code_placeholder() }

public func tfaCodeFieldAutoFillStyle(_ textField: UITextField) -> UITextField {
  let style = textField
    |> tfaCodeFieldStyle

  if #available(iOS 12, *) {
    return style
      |> \.textContentType .~ .oneTimeCode
  }
  return style
}

public let twoFactorControllerStyle = UIViewController.lens.title %~ { _ in Strings.two_factor_title() }
