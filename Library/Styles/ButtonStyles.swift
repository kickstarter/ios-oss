import Prelude
import Prelude_UIKit
import UIKit

private let baseButtonStyle = roundedStyle()
  <> UIButton.lens.titleLabel.font .~ .ksr_callout
  <> UIButton.lens.contentEdgeInsets .~ .init(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
  <> UIButton.lens.adjustsImageWhenDisabled .~ false
  <> UIButton.lens.adjustsImageWhenHighlighted .~ false

public let blackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_black
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_white
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_green
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_gray

public let borderButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_darkGrayText
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_clear
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_lightGrayText
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_gray
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .ksr_gray
  <> UIButton.lens.titleLabel.font .~ .ksr_callout
  <> UIButton.lens.contentEdgeInsets .~ .init(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_gray.CGColor
  <> UIButton.lens.layer.borderWidth .~ 1.0

public let facebookButtonStyle = roundedStyle()
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_facebookBlue
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_darkBlue
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_darkBlue
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.titleLabel.font .~ .ksr_callout
  <> UIButton.lens.contentEdgeInsets .~ .init(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.login_tout_buttons_log_in_with_facebook()
}

public let neutralButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_darkGray
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_blackGray
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_gray

public let positiveButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_green
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_darkGreen
  <> UIButton.lens.titleColor(forState: .Disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(forState: .Disabled) .~ .ksr_gray
