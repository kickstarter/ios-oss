import Prelude
import Prelude_UIKit
import UIKit

public let baseButtonStyle =
  roundedStyle(cornerRadius: 2)
    <> UIButton.lens.titleLabel.font %~~ { _, button in
      button.traitCollection.verticalSizeClass == .Compact
        ? .ksr_callout(size: 12)
        : .ksr_callout(size: 14)
    }
    <> UIButton.lens.contentEdgeInsets %~~ { _, button in
      button.traitCollection.verticalSizeClass == .Compact
        ? .init(topBottom: 10.0, leftRight: 12.0)
        : .init(topBottom: 13.0, leftRight: 16.0)
    }
    <> UIButton.lens.adjustsImageWhenDisabled .~ false
    <> UIButton.lens.adjustsImageWhenHighlighted .~ false

public let blackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .blackColor()
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_green_400
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_grey_500

public let borderButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_600
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .clearColor()
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_navy_900
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_500
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .ksr_grey_500
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_500.CGColor
  <> UIButton.lens.layer.borderWidth .~ 1.0

public let greenBorderButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_green_700
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_green_400
  <> UIButton.lens.titleColor(forState: .Disabled) .~ UIColor.ksr_green_700.colorWithAlphaComponent(0.5)
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_green_700.CGColor
  <> UIButton.lens.layer.borderWidth .~ 1.0

public let greenBorderContainerButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_green_700
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_green_700
  <> UIButton.lens.titleColor(forState: .Disabled) .~ UIColor.ksr_green_700.colorWithAlphaComponent(0.5)
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_green_500.CGColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 10.0, leftRight: Styles.grid(3))

public let facebookButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_facebookBlue
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_900
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_navy_900
  <> UIButton.lens.tintColor .~ .whiteColor()
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 24.0)
  <> UIButton.lens.image(forState: .Normal) %~ { _ in image(named: "fb-logo-white") }

public let facebookThanksButtonStyle = facebookButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.project_checkout_share_buttons_share()
}

public let neutralButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_navy_500
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_600
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_navy_400

public let greenButtonStyle =
  baseButtonStyle
    <> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_green_500
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_green_700
    <> UIButton.lens.titleColor(forState: .Disabled) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Disabled)
      .~ UIColor.ksr_green_400.colorWithAlphaComponent(0.5)
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_green_700.CGColor
    <> UIButton.lens.layer.borderWidth .~ 1.0

public let lightNavyButtonStyle =
  baseButtonStyle
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_navy_200
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_900
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_400
    <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 0.0, alpha: 0.4)
    <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_navy_600
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_300.CGColor
    <> UIButton.lens.layer.borderWidth .~ 1.0

public let navyButtonStyle =
  baseButtonStyle
    <> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_navy_700
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_600
    <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 0.0, alpha: 0.4)
    <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_navy_600
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_900.CGColor
    <> UIButton.lens.layer.borderWidth .~ 1.0

public let textOnlyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_900
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .clearColor()
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_green_400
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .ksr_navy_500

public let twitterButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_twitterBlue
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_900
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_navy_900
  <> UIButton.lens.tintColor .~ .whiteColor()
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 24.0)
  <> UIButton.lens.image(forState: .Normal) %~ { _ in image(named: "twitter-logo-blue") }
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.project_checkout_share_buttons_tweet()
}
