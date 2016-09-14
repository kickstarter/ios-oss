import Prelude
import Prelude_UIKit
import UIKit

public let createNewAccountButtonStyle = greenButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.facebook_confirmation_button() }

public let disclaimerButtonStyle =
    UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_500
      <> UIButton.lens.titleLabel.font .~ .ksr_footnote()
      <> UIButton.lens.titleLabel.textAlignment .~ .Center
      <> UIButton.lens.contentEdgeInsets .~ .init(top: 0, left: 16, bottom: 0, right: 16)
      <> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.login_tout_disclaimer_by_signing_up_you_agree_to_terms()
      }
      <> UIButton.lens.accessibilityValue %~ { _ in Strings.general_navigation_buttons_help() }
      <> UIButton.lens.accessibilityLabel %~ { _ in
        Strings.login_tout_disclaimer_by_signing_up_you_agree_to_terms()
      }
      <> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_help_sheet() }

public let emailFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in Strings.login_placeholder_email() }
  <> UITextField.lens.keyboardType .~ .EmailAddress

public let fbConfirmationMessageLabelStyle = UILabel.lens.textColor .~ .ksr_text_navy_900
  <> UILabel.lens.font .~ .ksr_body()
  <> UILabel.lens.text %~ { _ in Strings.Youre_about_to_create_a_new_Kickstarter_account() }

public let fbConfirmEmailLabelStyle =  UILabel.lens.textColor .~ .ksr_text_navy_700
  <> UILabel.lens.font .~ .ksr_headline()
  <> UILabel.lens.textAlignment .~ .Left
  <> UILabel.lens.adjustsFontSizeToFitWidth .~ true

public let fbDisclaimerLabelStyle = UILabel.lens.font .~ .ksr_footnote()
  <> UILabel.lens.textColor .~ .ksr_text_navy_500
  <> UILabel.lens.textAlignment .~ .Center
  <> UILabel.lens.text %~ { _ in
    Strings.discovery_facebook_connect_hero_we_will_never_post_anything_on_facebook()
}

public let fbLoginStackViewStyle =
  UIStackView.lens.alignment %~~ { _, stack in
    stack.traitCollection.horizontalSizeClass == .Compact ? .Fill : .Center
}

public let fbWrongAccountLabelStyle = UILabel.lens.font .~ .ksr_caption1()
  <> UILabel.lens.textColor .~ .ksr_text_navy_700
  <> UILabel.lens.text %~ { _ in Strings.facebook_confirmation_wrong_account_title() }

public let forgotPasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_subhead()
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_500
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .blackColor()

public let loginButtonStyle = greenButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.login_tout_back_intent_traditional_login_button()
}

public let loginControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in
    Strings.login_navbar_title()
}

public let loginSignupButtonsStackViewStyle =
  UIStackView.lens.axis %~~ { _, stack in
    stack.traitCollection.verticalSizeClass ==  .Compact ? .Horizontal : .Vertical
}

public let loginWithEmailButtonStyle = borderButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.login_buttons_log_in_email() }

public let onePasswordButtonStyle =
  UIButton.lens.titleLabel.font .~ .ksr_callout()
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_onePasswordBlue
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_navy_500
    <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.login_buttons_one_password() }

public let newsletterLabelStyle = UILabel.lens.font .~ .ksr_footnote()
  <> UILabel.lens.textColor .~ .ksr_text_navy_700
  <> UILabel.lens.text %~ { _ in Strings.signup_newsletter_full() }

public let passwordFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in Strings.login_placeholder_password() }
  <> UITextField.lens.secureTextEntry .~ true

public let resetPasswordButtonStyle = greenButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.forgot_password_buttons_reset_my_password() }

public let resetPasswordControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in Strings.forgot_password_title() }

public let loginRootStackViewStyle =
  UIStackView.lens.layoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.layoutMargins %~~ { _, stack in
      stack.traitCollection.horizontalSizeClass == .Compact ? .init(all: 16.0) : .init(all: 64.0)
}

public let signupButtonStyle = greenButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.login_tout_default_intent_traditional_signup_button()
}

public let signupControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in Strings.signup_button() }

public let signupWithEmailButtonStyle = borderButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.signup_button_email() }

public let tfaCodeFieldStyle = formFieldStyle
  <> UITextField.lens.textAlignment .~ .Center
  <> UITextField.lens.font .~ .ksr_title1()
  <> UITextField.lens.keyboardType .~ .NumberPad
  <> UITextField.lens.placeholder %~ { _ in Strings.two_factor_code_placeholder() }

public let twoFactorControllerStyle = baseControllerStyle()
  <> UIViewController.lens.title %~ { _ in Strings.two_factor_title() }
