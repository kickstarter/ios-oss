import Prelude
import Prelude_UIKit
import UIKit

// MARK: - Apple Pay

public let applePayButtonStyle: ButtonStyle = { button in
  button
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> \.isAccessibilityElement .~ true
}

// MARK: - Base

public let baseButtonStyle: ButtonStyle = { button in
  button
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_callout().bolded
    |> (UIButton.lens.titleLabel .. UILabel.lens.textAlignment) .~ NSTextAlignment.center
    |> UIButton.lens.contentEdgeInsets .~ .init(all: Styles.grid(2))
    |> UIButton.lens.titleLabel .. UILabel.lens.lineBreakMode .~ NSLineBreakMode.byTruncatingMiddle
    |> UIButton.lens.titleLabel .. UILabel.lens.numberOfLines .~ 1
    |> UIButton.lens.adjustsImageWhenDisabled .~ false
    |> UIButton.lens.adjustsImageWhenHighlighted .~ false
}

// MARK: - Apricot

public let apricotButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_black
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_apricot_500
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_text_black
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_dark_grey_400
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_apricot_500.mixDarker(0.12)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_apricot_500.mixLighter(0.36)

// MARK: - Black

public let blackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_soft_black
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_soft_black.mixDarker(0.66)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_soft_black.mixLighter(0.36)

// MARK: - Blue

public let blueButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_blue_500
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_blue_500.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_blue_500.mixLighter(0.36)

// MARK: - Green

public let greenButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_green_500
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_green_500.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_green_500.mixLighter(0.36)

// MARK: - Grey

public let greyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_black
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_grey_500
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_text_black
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_dark_grey_400
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_grey_500.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_grey_500.mixLighter(0.12)

// MARK: - Facebook

public let facebookButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_facebookBlue
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_facebookBlue.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_facebookBlue.mixLighter(0.36)
  <> UIButton.lens.tintColor .~ .white
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 18.0)
  <> UIButton.lens.contentEdgeInsets %~~ { _, button in
    button.traitCollection.verticalSizeClass == .compact
      ? .init(topBottom: 10.0, leftRight: 12.0)
      : .init(topBottom: 12.0, leftRight: 16.0)
  }

  <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "fb-logo-white") }

// MARK: - Red

public let redButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_red_400
  <> UIButton.lens.titleColor(for: .highlighted) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_red_400.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_red_400.mixLighter(0.36)

public let saveButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.tintColor .~ .ksr_soft_black
  <> UIButton.lens.image(for: .normal) .~ image(named: "icon--heart-outline")
  <> UIButton.lens.image(for: .selected) .~ image(named: "icon--heart")
  <> UIButton.lens.accessibilityLabel %~ { _ in Strings.Save_this_project() }

public let shareButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.image(for: .normal) .~ image(named: "icon--share")
  <> UIButton.lens.tintColor .~ .ksr_soft_black
  <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

// Remove when DeprecatedRewardShippingPickerViewController is removed.
public let textOnlyButtonStyle = roundedStyle(cornerRadius: 0)
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
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_soft_black
  <> UIButton.lens.backgroundColor(for: .normal) .~ .clear
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_green_400
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_dark_grey_400
