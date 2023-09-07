import Prelude
import Prelude_UIKit
import UIKit

public enum DesignSystemColor: String {
  // MARK: - Greens

  case create100
  case create300
  case create500
  case create700

  // MARK: - Greys

  case black
  case support100
  case support200
  case support300
  case support400
  case support500
  case support700
  case white

  // MARK: - Blues

  case trust100
  case trust300
  case trust500
  case trust700

  // MARK: - Corals

  case celebrate100
  case celebrate300
  case celebrate500
  case celebrate700

  // MARK: - Functional

  case alert
  case cellSeparator
  case facebookBlue
  case inform
  case warn
}

extension DesignSystemColor {
  public func load() -> UIColor {
    UIColor(named: self.rawValue) ?? .white
  }
}

public func adaptiveColor(_ style: DesignSystemColor) -> UIColor {
  style.load()
}

// MARK: - Buttons

public let adaptiveGreenButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.create700)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.create700).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.create700).mixLighter(0.36)

public let adaptiveBlueButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.trust500)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.trust500).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.trust500).mixLighter(0.36)

public let adaptiveGreyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.support700)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.support300)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.support700)
  <> UIButton.lens.titleColor(for: .disabled) .~ adaptiveColor(.support400)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.support300).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.support300).mixLighter(0.12)

public let adaptiveBlackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.white)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.white)
  <> UIButton.lens.titleColor(for: .disabled) .~ adaptiveColor(.support100)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.support700)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.support700).mixDarker(0.66)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.support700).mixLighter(0.36)
  <> UIButton.lens.backgroundColor(for: .selected) .~ adaptiveColor(.support700).mixLighter(0.46)

public let adaptiveRedButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.alert)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.alert).mixDarker(0.12)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.alert).mixLighter(0.36)

public let adaptiveFacebookButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.facebookBlue)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.white)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.facebookBlue).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.facebookBlue).mixLighter(0.36)
  <> UIButton.lens.tintColor .~ adaptiveColor(.white)
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 18.0)
  <> UIButton.lens.contentEdgeInsets %~~ { _, button in
    button.traitCollection.verticalSizeClass == .compact
      ? .init(topBottom: 10.0, leftRight: 12.0)
      : .init(topBottom: 12.0, leftRight: 16.0)
  }

  <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "fb-logo-white") }

// MARK: - Icons

public let adaptiveIconImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFit
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

// MARK: - Switch Control

public let adaptiveSwitchControlStyle: SwitchControlStyle = { switchControl in
  switchControl
    |> \.onTintColor .~ adaptiveColor(.create700)
    |> \.tintColor .~ adaptiveColor(.support100)
}

// MARK: - Form

public let adaptiveFormFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> formTextInputStyle
    |> \.backgroundColor .~ .clear
    |> \.borderStyle .~ UITextField.BorderStyle.none
    |> \.font .~ .ksr_body()
    |> \.textColor .~ .black
    |> \.tintColor .~ adaptiveColor(.create700)
}

// MARK: - Text Field

public let adaptiveEmailFieldStyle = adaptiveFormFieldStyle
  <> UITextField.lens.keyboardType .~ .emailAddress

public func adaptiveAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: adaptiveColor(.support400)]
  )
}

private let adaptiveEmailTextFieldPlaceholderStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.returnKeyType .~ UIReturnKeyType.next
    |> \.attributedPlaceholder %~ { _ in
      adaptiveAttributedPlaceholder(Strings.login_placeholder_email())
    }
}

public let adaptivePasswordFieldStyle = formFieldStyle
  <> UITextField.lens.secureTextEntry .~ true

private let adaptivePasswordTextFieldPlaceholderStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.returnKeyType .~ UIReturnKeyType.done
    |> \.attributedPlaceholder %~ { _ in
      adaptiveAttributedPlaceholder(Strings.login_placeholder_password())
    }
}

// MARK: - Activity Indicator

public func adaptiveActivityIndicatorStyle(indicator: UIActivityIndicatorView) -> UIActivityIndicatorView {
  return indicator
    |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
    |> UIActivityIndicatorView.lens.style .~ .medium
    |> UIActivityIndicatorView.lens.color .~ adaptiveColor(.support700)
}

// MARK: - Links

public let adaptiveTappableLinksViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  _ = textView
    |> \.isScrollEnabled .~ false
    |> \.isEditable .~ false
    |> \.isUserInteractionEnabled .~ true
    |> \.adjustsFontForContentSizeCategory .~ true

  _ = textView
    |> \.textContainerInset .~ UIEdgeInsets.zero
    |> \.textContainer.lineFragmentPadding .~ 0
    |> \.linkTextAttributes .~ [
      .foregroundColor: adaptiveColor(.create700)
    ]

  return textView
}
