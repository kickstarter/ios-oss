import Prelude
import Prelude_UIKit
import UIKit

public let createNewAccountButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.facebook_confirmation_button()
}

public let disclaimerButtonStyle =
  UIButton.lens.titleLabel %~ disclaimerLabelStyle
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_darkGray
    <> UIButton.lens.contentEdgeInsets .~ .init(top: 0, left: 16, bottom: 0, right: 16)
    <> UIButton.lens.contentHorizontalAlignment .~ .Center

public let disclaimerLabelStyle = UILabel.lens.font .~ .ksr_footnote
  <> UILabel.lens.textColor .~ .ksr_darkGray
  <> UILabel.lens.textAlignment .~ .Center

public let emailFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in
    Strings.login_placeholder_email()
  }
  <> UITextField.lens.keyboardType .~ .EmailAddress

public let forgotPasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_subhead
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_darkGray
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_black

public let loginButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.login_tout_back_intent_traditional_login_button()
}

public let loginControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in
    Strings.login_navbar_title()
}

public let loginWithEmailButtonStyle = borderButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.login_buttons_log_in_email()
}

public let onePasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_callout
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_blue
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_lightBlue
    <> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.login_buttons_one_password() }

public let newsletterLabelStyle = UILabel.lens.font .~ .ksr_subhead
  <> UILabel.lens.textColor .~ .ksr_textDefault

public let passwordFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in
    Strings.login_placeholder_password()
  }
  <> UITextField.lens.secureTextEntry .~ true

public let resetPasswordButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.forgot_password_buttons_reset_my_password()
}

public let resetPasswordControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in
    Strings.forgot_password_title()
}

public let signupButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.login_tout_default_intent_traditional_signup_button()
}

public let signupControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title .~ Strings.signup_button()

public let signupWithEmailButtonStyle = borderButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.signup_button_email()
}

public let tfaCodeFieldStyle = formFieldStyle
  <> UITextField.lens.textAlignment .~ .Center
  <> UITextField.lens.font .~ .ksr_title1
  <> UITextField.lens.keyboardType .~ .NumberPad
  <> UITextField.lens.placeholder %~ { _ in
    Strings.two_factor_code_placeholder()
}

public let twoFactorControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in
    Strings.two_factor_title()
}
