import Prelude
import UIKit

// MARK: - Constants

public enum CheckoutConstants {
  public enum RewardCard {
    public enum Layout {
      public static let width: CGFloat = 249
    }

    public enum Transition {
      public enum DepressAnimation {
        public static let scaleFactor: CGFloat = 0.975
        public static let duration: TimeInterval = 0.0967
        public static let longPressMinimumDuration: TimeInterval = 0.001
      }
    }
  }
}

// MARK: - Attributes

public func checkoutCurrencyDefaultAttributes() -> String.Attributes {
  return [
    .font: UIFont.ksr_title1(),
    .foregroundColor: UIColor.ksr_text_dark_grey_500
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
  }
}

public func checkoutAdaptableStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .leading : .center)
    let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
    let distribution: UIStackView.Distribution = (isAccessibilityCategory ? .equalSpacing : .fill)
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return stackView
      |> \.alignment .~ alignment
      |> \.axis .~ axis
      |> \.distribution .~ distribution
      |> \.spacing .~ spacing
  }
}

public let checkoutGreenButtonStyle: ButtonStyle = { button -> UIButton in
  button
    |> greenButtonStyle
    |> roundedStyle(cornerRadius: 12)
    |> UIButton.lens.layer.borderWidth .~ 0
    |> UIButton.lens.titleEdgeInsets .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
}

public let checkoutGreenButtonTitleLabelStyle = { (titleLabel: UILabel?) -> UILabel? in
  _ = titleLabel
    ?|> \.font .~ UIFont.ksr_headline()
    ?|> \.numberOfLines .~ 0

  _ = titleLabel
    ?|> \.textAlignment .~ NSTextAlignment.center
    ?|> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping

  return titleLabel
}

public let checkoutBackgroundStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_grey_300
}

public let checkoutRoundedCornersStyle: ViewStyle = { (view: UIView) in
  view
    |> \.layer.cornerRadius .~ 6
}

public let checkoutStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ (Styles.grid(1) + Styles.gridHalf(1))
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
    |> \.backgroundColor .~ UIColor.white
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
      .foregroundColor: UIColor.ksr_green_500
    ]

  return textView
}

public func checkoutAttributedLink(with string: String) -> NSAttributedString? {
  guard let attributedString = try? NSMutableAttributedString(
    data: Data(string.utf8),
    options: [.documentType: NSAttributedString.DocumentType.html],
    documentAttributes: nil
  ) else { return nil }

  let attributes: String.Attributes = [
    .font: UIFont.ksr_caption1(),
    .foregroundColor: UIColor.ksr_text_dark_grey_500,
    .underlineStyle: 0
  ]

  let fullRange = (attributedString.string as NSString).range(of: attributedString.string)

  attributedString.addAttributes(attributes, range: fullRange)

  return attributedString
}

public let rewardCardShadowStyle: ViewStyle = { (view: UIView) in
  view
    |> dropShadowStyleMedium()
    |> \.layer.shouldRasterize .~ false
}
