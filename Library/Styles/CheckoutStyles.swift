import Prelude
import UIKit

// MARK: - Types

public enum ButtonStyleType: Equatable {
  case black
  case blue
  case green
  case grey
  case none
  case red

  public var style: ButtonStyle {
    switch self {
    case .black: return blackButtonStyle
    case .blue: return blueButtonStyle
    case .green: return greenButtonStyle
    case .grey: return greyButtonStyle
    case .none: return { $0 }
    case .red: return redButtonStyle
    }
  }
}

// MARK: - Constants

public enum CheckoutConstants {
  public enum CreditCardView {
    public static let height: CGFloat = 143
  }

  public enum PledgeView {
    public enum Inset {
      public static let leftRight: CGFloat = Styles.grid(4)
    }
  }

  public enum RewardCard {
    public enum Layout {
      public static let width: CGFloat = 294
    }
  }

  public enum PaymentSource {
    public enum Card {
      public static let width: CGFloat = 240
    }

    public enum ImageView {
      public static let width: CGFloat = 64
      public static let height: CGFloat = 40
    }

    public enum Button {
      public static let width: CGFloat = 217
    }
  }
}

// MARK: - Attributes

public func checkoutCurrencyDefaultAttributes() -> String.Attributes {
  return [
    .font: UIFont.ksr_title1(),
    .foregroundColor: UIColor.ksr_support_400
  ]
}

public func checkoutCurrencySuperscriptAttributes() -> String.Attributes {
  return [
    .font: UIFont.ksr_body(),
    .baselineOffset: UIFont.ksr_body().baselineOffsetToSuperscript(of: UIFont.ksr_title1())
  ]
}

// MARK: - Styles

public enum Layout {
  public enum Sheet {
    public static let offset: CGFloat = 222
    public static let offsetCompact: CGFloat = 44
  }
}

public let checkoutBackgroundStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_support_100
}

public let checkoutLabelStyle: LabelStyle = { label in
  label
    |> \.backgroundColor .~ UIColor.ksr_support_100
}

public let checkoutRoundedCornersStyle: ViewStyle = { (view: UIView) in
  view
    |> \.layer.cornerRadius .~ 6
}

public let checkoutStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ (Styles.grid(1) + Styles.gridHalf(1))
}

public let checkoutSwitchControlStyle: SwitchControlStyle = { switchControl in
  switchControl
    |> \.onTintColor .~ UIColor.ksr_create_700
    |> \.tintColor .~ UIColor.ksr_support_300
}

public let checkoutStepperStyle: (UIStepper) -> UIStepper = { stepper in
  stepper
    |> \.stepValue .~ 1.0
    |> \.tintColor .~ UIColor.clear
    <> UIStepper.lens.decrementImage(for: .normal) .~ image(named: "stepper-decrement-normal")
    <> UIStepper.lens.decrementImage(for: .disabled) .~ image(named: "stepper-decrement-disabled")
    <> UIStepper.lens.decrementImage(for: .highlighted) .~ image(named: "stepper-decrement-highlighted")
    <> UIStepper.lens.incrementImage(for: .normal) .~ image(named: "stepper-increment-normal")
    <> UIStepper.lens.incrementImage(for: .disabled) .~ image(named: "stepper-increment-disabled")
    <> UIStepper.lens.incrementImage(for: .highlighted) .~ image(named: "stepper-increment-highlighted")
}

public let checkoutTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.accessibilityTraits .~ UIAccessibilityTraits.header
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_headline(size: 15)
    |> \.numberOfLines .~ 0
}

public let checkoutWhiteBackgroundStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_white
}

public let checkoutLayerCardRoundedStyle: LayerStyle = { layer in
  layer
    |> \.cornerRadius .~ 16.0
}

public let tappableLinksViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  _ = textView
    |> \.isScrollEnabled .~ false
    |> \.isEditable .~ false
    |> \.isUserInteractionEnabled .~ true
    |> \.adjustsFontForContentSizeCategory .~ true

  _ = textView
    |> \.textContainerInset .~ UIEdgeInsets.zero
    |> \.textContainer.lineFragmentPadding .~ 0
    |> \.linkTextAttributes .~ [
      .foregroundColor: UIColor.ksr_create_700
    ]

  return textView
}

public func checkoutAttributedLink(with string: String) -> NSAttributedString? {
  guard let attributedString = try? NSMutableAttributedString(
    data: Data(string.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let attributes: String.Attributes = [
    .font: UIFont.ksr_caption1(),
    .foregroundColor: UIColor.ksr_support_400,
    .underlineStyle: 0
  ]

  let fullRange = (attributedString.string as NSString).range(of: attributedString.string)

  attributedString.addAttributes(attributes, range: fullRange)

  return attributedString
}

public let checkoutCardStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

public let checkoutRootStackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
    |> \.spacing .~ Styles.grid(4)
}

public let checkoutSubStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.spacing .~ Styles.grid(3)
}

public let rewardCardShadowStyle: ViewStyle = { (view: UIView) in
  view
    |> dropShadowStyleMedium()
    |> \.layer.shouldRasterize .~ false
}

public let cardImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFit
}

public let cardSelectButtonStyle: ButtonStyle = { button in
  button
    |> blackButtonStyle
}

public let pledgeCardViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_white
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
}
