import Prelude
import Prelude_UIKit
import UIKit

public let createNewAccountButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    localizedString(key: "facebook_confirmation.button", defaultValue: "Create new account")
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
    localizedString(key: "login.placeholder_email", defaultValue: "Email")
  }
  <> UITextField.lens.keyboardType .~ .EmailAddress

public let forgotPasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_subhead
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_darkGray
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_black

public let loginButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    localizedString(key: "login_tout.default_intent.traditional_login_button", defaultValue: "Log in")
}

public let loginControllerStyle = baseControllerStyle
  <> UIViewController.lens.title %~ { _ in
    localizedString(key: "login.navbar.title", defaultValue: "Log in")
}

public let loginToutControllerStyle = baseControllerStyle

public let loginWithEmailButtonStyle = borderButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    localizedString(key: "login.buttons.log_in_email", defaultValue: "Log in with email")
}

public let newsletterLabelStyle = UILabel.lens.font .~ .ksr_subhead
  <> UILabel.lens.textColor .~ .ksr_textDefault

public let passwordFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in
    localizedString(key: "login.placeholder_password", defaultValue: "Password")
  }
  <> UITextField.lens.secureTextEntry .~ true

public let resetPasswordButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    localizedString(key: "forgot_password.buttons.reset_my_password", defaultValue: "Reset my password")
}

public let resetPasswordControllerStyle = baseControllerStyle
  <> UIViewController.lens.title %~ { _ in
    localizedString(key: "forgot_password.title", defaultValue: "Forgot your password?")
}

public let signupButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    localizedString(key: "login_tout.default_intent.traditional_signup_button", defaultValue: "Sign up")
}

public let signupControllerStyle = baseControllerStyle
  <> UIViewController.lens.title .~ localizedString(key: "adf", defaultValue: "Sign up")

public let signupWithEmailButtonStyle = borderButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    localizedString(key: "signup.button_email", defaultValue: "Sign up with email")
}

public let tfaCodeFieldStyle = formFieldStyle
  <> UITextField.lens.textAlignment .~ .Center
  <> UITextField.lens.font .~ .ksr_title1
  <> UITextField.lens.keyboardType .~ .NumberPad
  <> UITextField.lens.placeholder %~ { _ in
    localizedString(key: "two_factor.code_placeholder", defaultValue: "Enter code")
}

public let twoFactorControllerStyle = baseControllerStyle
  <> UIViewController.lens.title %~ { _ in
    localizedString(key: "two_factor.title", defaultValue: "Verify")
}
