import Prelude
import Prelude_UIKit
import UIKit

public enum DesignSystemColorSet: String {
  case old = "colors-old"
  case new = "colors-new"
}

public enum DesignSystemCoreColors: String {
  // MARK: - OLD COLORS

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

  // MARK: NEW COLORS

  // MARK: Blues

  case blue1
  case blue2
  case blue3
  case blue4
  case blue5
  case blue6
  case blue7
  case blue8
  case blue9
  case blue10

  // MARK: Greens

  case green1
  case green2
  case green3
  case green4
  case green5
  case green6
  case green7
  case green8
  case green9
  case green10

  // MARK: Greys

  case grey1
  case grey2
  case grey3
  case grey4
  case grey5
  case grey6
  case grey7
  case grey8
  case grey9
  case grey10

  // MARK: Oranges

  case orange1
  case orange2
  case orange3
  case orange4
  case orange5
  case orange6
  case orange7
  case orange8
  case orange9
  case orange10

  // MARK: Purples

  case purple1
  case purple2
  case purple3
  case purple4
  case purple5
  case purple6
  case purple7
  case purple8
  case purple9
  case purple10

  // MARK: Reds

  case red1
  case red2
  case red3
  case red4
  case red5
  case red6
  case red7
  case red8
  case red9
  case red10

  // MARK: Yellows

  case yellow1
  case yellow2
  case yellow3
  case yellow4
  case yellow5
  case yellow6
  case yellow7
  case yellow8
  case yellow9
  case yellow10
}

extension DesignSystemCoreColors {
  public func load(_ colorSet: DesignSystemColorSet) -> UIColor {
    UIColor(named: "\(colorSet.rawValue)/\(self.rawValue)") ?? .white
  }
}

public func adaptiveColor(_ colorSet: DesignSystemColorSet, _ style: DesignSystemCoreColors) -> UIColor {
  style.load(colorSet)
}

// MARK: Component Styles

/// New component style examples.
/// Essentially a copy/paste of how we're currently using Prelude to set component styles. These just take advantage of the new adaptiveColor pattern above.
public let verticalComponentStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> verticalStackViewStyle
    |> \.alignment .~ .leading
    |> \.spacing .~ 8
    |> \.distribution .~ .fill
    |> UIStackView.lens.spacing .~ Styles.grid(2)
}

// MARK: - Alert StackView

public let alertStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.distribution .~ .fill
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: 8, leftRight: 12)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ 12
    |> \.tintColor .~ .white
    |> \.layer.cornerRadius .~ 6
}

// MARK: - Buttons

public let adaptiveGreenButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.old, .create700)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.old, .create700).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.old, .create700).mixLighter(0.36)

public let adaptiveBlueButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.old, .trust500)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.old, .trust500).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.old, .trust500).mixLighter(0.36)

public let adaptiveGreyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.old, .support700)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.old, .support300)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.old, .support700)
  <> UIButton.lens.titleColor(for: .disabled) .~ adaptiveColor(.old, .support400)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.old, .support300).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.old, .support300).mixLighter(0.12)

public let adaptiveBlackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.titleColor(for: .disabled) .~ adaptiveColor(.old, .support100)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.old, .support700)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.old, .support700).mixDarker(0.66)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.old, .support700).mixLighter(0.36)
  <> UIButton.lens.backgroundColor(for: .selected) .~ adaptiveColor(.old, .support700).mixLighter(0.46)

public let adaptiveRedButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.old, .white)
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.old, .alert)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.old, .alert).mixDarker(0.12)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.old, .alert).mixLighter(0.36)

public let adaptiveFacebookButtonStyle = baseButtonStyle
  <> UIButton.lens.backgroundColor(for: .normal) .~ adaptiveColor(.old, .facebookBlue)
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ adaptiveColor(.old, .facebookBlue).mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ adaptiveColor(.old, .facebookBlue).mixLighter(0.36)
  <> UIButton.lens.tintColor .~ adaptiveColor(.old, .white)
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
    |> \.onTintColor .~ adaptiveColor(.old, .create700)
    |> \.tintColor .~ adaptiveColor(.old, .support100)
}

// MARK: - Drop Down

public let adaptiveDropDownButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> UIButton.lens.contentEdgeInsets .~ UIEdgeInsets(
      top: Styles.gridHalf(3), left: Styles.grid(2), bottom: Styles.gridHalf(3), right: Styles.grid(5)
    )
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_body().bolded
    |> UIButton.lens.titleColor(for: .normal) .~ adaptiveColor(.old, .create500)
    |> UIButton.lens.titleColor(for: .highlighted) .~ adaptiveColor(.old, .create500)
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "icon-dropdown-small")
    |> UIButton.lens.semanticContentAttribute .~ .forceRightToLeft
    |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(top: 0, left: Styles.grid(6), bottom: 0, right: 0)
    |> UIButton.lens.layer.shadowColor .~ adaptiveColor(.old, .black).cgColor
}

// MARK: - Form

public let adaptiveFormFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> formTextInputStyle
    |> \.backgroundColor .~ .clear
    |> \.font .~ .ksr_body()
    |> \.textColor .~ adaptiveColor(.old, .black)
}

// MARK: - Text Field

public let adaptiveEmailFieldStyle = adaptiveFormFieldStyle
  <> UITextField.lens.keyboardType .~ .emailAddress

public func adaptiveAttributedPlaceholder(_ string: String) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: adaptiveColor(.old, .support400)]
  )
}

private let adaptiveEmailTextFieldPlaceholderStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.returnKeyType .~ UIReturnKeyType.next
    |> \.attributedPlaceholder %~ { _ in
      adaptiveAttributedPlaceholder(Strings.login_placeholder_email())
    }
}

// MARK: - Activity Indicator

public func adaptiveActivityIndicatorStyle(indicator: UIActivityIndicatorView) -> UIActivityIndicatorView {
  return indicator
    |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
    |> UIActivityIndicatorView.lens.style .~ .medium
    |> UIActivityIndicatorView.lens.color .~ adaptiveColor(.old, .support700)
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
      .foregroundColor: adaptiveColor(.old, .create700)
    ]

  return textView
}
