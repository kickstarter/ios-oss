import Prelude
import Prelude_UIKit
import UIKit

public let baseButtonStyle =
  roundedStyle(cornerRadius: 0)
    <> UIButton.lens.titleLabel.font %~~ { _, button in
      button.traitCollection.verticalSizeClass == .compact
        ? .ksr_callout(size: 12)
        : .ksr_callout(size: 14)
    }
    <> UIButton.lens.contentEdgeInsets %~~ { _, button in
      button.traitCollection.verticalSizeClass == .compact
        ? .init(topBottom: 10.0, leftRight: 12.0)
        : .init(topBottom: 13.0, leftRight: 16.0)
    }
    <> UIButton.lens.adjustsImageWhenDisabled .~ false
    <> UIButton.lens.adjustsImageWhenHighlighted .~ false

public let blackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_dark_grey_900
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_dark_grey_400
  <> UIButton.lens.titleColor(for: .disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ .ksr_dark_grey_400

public let borderButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_dark_grey_900
  <> UIButton.lens.backgroundColor(for: .normal) .~ .clear
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_dark_grey_900
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_grey_400
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_grey_400
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_dark_grey_900.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0

public let greenBorderButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_700
  <> UIButton.lens.backgroundColor(for: .normal) .~ .white
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_green_400
  <> UIButton.lens.titleColor(for: .disabled) .~ UIColor.ksr_green_700.withAlphaComponent(0.5)
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_green_700.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0

public let facebookButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_facebookBlue
  <> UIButton.lens.titleColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_dark_grey_900
  <> UIButton.lens.titleColor(for: .disabled) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ .ksr_dark_grey_900
  <> UIButton.lens.tintColor .~ .white
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 24.0)
  <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "fb-logo-white") }

public let facebookThanksButtonStyle = facebookButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.project_checkout_share_buttons_share()
}

public let neutralButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_dark_grey_400
  <> UIButton.lens.titleColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_dark_grey_500
  <> UIButton.lens.titleColor(for: .disabled) .~ .init(white: 1.0, alpha: 0.75)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ .ksr_navy_400

public let greenButtonStyle =
  baseButtonStyle
    <> UIButton.lens.titleColor(for: .normal) .~ .white
    <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_green_500
    <> UIButton.lens.titleColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
    <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_green_700
    <> UIButton.lens.titleColor(for: .disabled) .~ .white
    <> UIButton.lens.backgroundColor(for: .disabled)
      .~ UIColor.ksr_green_500.withAlphaComponent(0.5)
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_green_700.cgColor
    <> UIButton.lens.layer.borderWidth .~ 1.0

public let lightNavyButtonStyle =
  baseButtonStyle
    <> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
    <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_navy_200
    <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_text_dark_grey_900
    <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_navy_400
    <> UIButton.lens.titleColor(for: .disabled) .~ .init(white: 0.0, alpha: 0.4)
    <> UIButton.lens.backgroundColor(for: .disabled) .~ .ksr_navy_600
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_300.cgColor
    <> UIButton.lens.layer.borderWidth .~ 1.0

public let navyButtonStyle =
  baseButtonStyle
    <> UIButton.lens.titleColor(for: .normal) .~ .white
    <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_dark_grey_900
    <> UIButton.lens.titleColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
    <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_dark_grey_500
    <> UIButton.lens.titleColor(for: .disabled) .~ .init(white: 0.0, alpha: 0.4)
    <> UIButton.lens.backgroundColor(for: .disabled) .~ .ksr_dark_grey_400
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_dark_grey_900.cgColor
    <> UIButton.lens.layer.borderWidth .~ 1.0

public let saveButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.tintColor .~ .ksr_dark_grey_900
  <> UIButton.lens.image(for: .normal) .~ image(named: "icon--heart-outline")
  <> UIButton.lens.image(for: .selected) .~ image(named: "icon--heart")
  <> UIButton.lens.accessibilityLabel %~ { _ in Strings.Save_this_project() }

public let shareButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.image(for: .normal) .~ image(named: "icon--share")
  <> UIButton.lens.tintColor .~ .ksr_dark_grey_900
  <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

public let textOnlyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_dark_grey_900
  <> UIButton.lens.backgroundColor(for: .normal) .~ .clear
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_green_400
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_dark_grey_400

public let twitterButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_twitterBlue
  <> UIButton.lens.titleColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_dark_grey_900
  <> UIButton.lens.titleColor(for: .disabled) .~ .init(white: 1.0, alpha: 0.5)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ .ksr_dark_grey_900
  <> UIButton.lens.tintColor .~ .white
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 24.0)
  <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "twitter-logo-blue") }
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.project_checkout_share_buttons_tweet()
}

public let whiteBorderButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .clear
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.white.withAlphaComponent(0.5)
  <> UIButton.lens.titleColor(for: .disabled) .~ UIColor.white.withAlphaComponent(0.5)
  <> UIButton.lens.layer.borderColor .~ UIColor.white.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.gridHalf(3), leftRight: Styles.gridHalf(6))
