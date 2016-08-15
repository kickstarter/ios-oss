import Prelude
import Prelude_UIKit
import UIKit

public let projectStatTitleStlye =
  UILabel.lens.font .~ UIFont.ksr_title2().bolded
    <> UILabel.lens.textColor .~ .ksr_text_navy_700

public let projectStatSubtitleStyle =
  UILabel.lens.font .~ .ksr_caption1()
    <> UILabel.lens.textColor .~ .ksr_text_navy_600

public let subpageTabButtonStyle =
  UIButton.lens.titleLabel.font .~ UIFont.ksr_headline(size: 14)
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_500
    <> UIButton.lens.titleColor(forState: .Selected) .~ .ksr_text_navy_700
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_green_700
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.grid(3), leftRight: 0)
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_300
    <> UIButton.lens.adjustsImageWhenHighlighted .~ false

public let projectNameAndBlurbStyle =
  SimpleHTMLLabel.lens.baseFont .~ .ksr_title3()
    <> SimpleHTMLLabel.lens.baseColor .~ .ksr_text_navy_600
    <> SimpleHTMLLabel.lens.boldFont .~ .ksr_title3()
    <> SimpleHTMLLabel.lens.boldColor .~ .ksr_text_navy_700
    <> SimpleHTMLLabel.lens.numberOfLines .~ 5
    <> SimpleHTMLLabel.lens.minimumScaleFactor .~ 0.5
    <> SimpleHTMLLabel.lens.adjustsFontSizeToFitWidth .~ true
    <> SimpleHTMLLabel.lens.lineBreakMode .~ .ByTruncatingTail
    <> SimpleHTMLLabel.lens.contentHuggingPriorityForAxis(.Vertical) .~ UILayoutPriorityRequired
    <> SimpleHTMLLabel.lens.contentCompressionResistancePriorityForAxis(.Vertical) .~ UILayoutPriorityRequired

public let contactCreatorButtonStyle =
  borderButtonStyle
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_navy_200
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_400
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_500
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_700
    <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 13)
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_400.CGColor
    <> UIButton.lens.adjustsImageWhenHighlighted .~ true
    <> UIButton.lens.tintColor .~ .ksr_text_navy_500
    <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: Styles.grid(2), bottom: 0, right: 0)
    <> UIButton.lens.title(forState: .Normal) %~ { _ in
      localizedString(key: "todo", defaultValue: "Ask me anything")
}

public let categoryLocationButtonStyle =
  borderButtonStyle
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 10, leftRight: 12)
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_200
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_500
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_navy_700
    <> UIButton.lens.adjustsImageWhenHighlighted .~ true
    <> UIButton.lens.tintColor .~ .ksr_text_navy_500
    <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: Styles.grid(1), bottom: 0, right: -Styles.grid(1))
    <> (UIButton.lens.contentEdgeInsets • UIEdgeInsets.lens.right) %~ { $0 + Styles.grid(1) }
    <> UIButton.lens.layer.cornerRadius .~ Styles.grid(3)
