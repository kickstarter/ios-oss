import Prelude
import Prelude_UIKit
import UIKit

// See `Kickstarter-iOS/SharedViews/ViewModifiers/ButtonModifiers.swift` for the SwiftUI version of
// these styles. These files should be kept in sync.

// TODO: replace this button styles using the new button KSRButton.swift. [MBL-2188](https://kickstarter.atlassian.net/browse/MBL-2188)

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
    |> UIButton.lens.contentEdgeInsets .~ .init(all: Styles.grid(2))
    |> UIButton.lens.adjustsImageWhenDisabled .~ false
    |> UIButton.lens.adjustsImageWhenHighlighted .~ false
    <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 16)
    <> UIButton.lens.titleLabel.lineBreakMode .~ NSLineBreakMode.byTruncatingMiddle
    <> UIButton.lens.titleLabel.textAlignment .~ NSTextAlignment.center
    <> UIButton.lens.titleLabel.numberOfLines .~ 1
}

// MARK: - Apricot

public let apricotButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_support_700
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_alert
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_support_700
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_support_400
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_alert.mixDarker(0.12)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_alert.mixLighter(0.36)

// MARK: - Red

public let redButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_white
  <> UIButton.lens.backgroundColor(for: .normal) .~ UIColor.ksr_alert
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_alert.mixDarker(0.12)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_alert.mixLighter(0.36)

// MARK: - Black

public let blackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_white
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_white
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_support_100
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_support_700
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_support_700.mixDarker(0.66)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_support_700.mixLighter(0.36)
  <> UIButton.lens.backgroundColor(for: .selected) .~ UIColor.ksr_support_700.mixLighter(0.46)

// MARK: - Blue

public let blueButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_trust_500
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_trust_500.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_trust_500.mixLighter(0.36)

// MARK: - Green

public let greenButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_create_700
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_create_700.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_create_700.mixLighter(0.36)

// MARK: - Grey

public let greyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_support_700
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_support_300
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_support_700
  <> UIButton.lens.titleColor(for: .disabled) .~ .ksr_support_400
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_support_300.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_support_300.mixLighter(0.12)

// MARK: - Facebook

public let facebookButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_facebookBlue
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ UIColor.ksr_facebookBlue.mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_facebookBlue.mixLighter(0.36)
  <> UIButton.lens.tintColor .~ .ksr_white
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 18.0)
  <> UIButton.lens.contentEdgeInsets %~~ { _, button in
    button.traitCollection.verticalSizeClass == .compact
      ? .init(topBottom: 10.0, leftRight: 12.0)
      : .init(topBottom: 12.0, leftRight: 16.0)
  }

  <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "fb-logo-white") }

public let fbFollowButtonStyle = facebookButtonStyle
  <> UIButton.lens.contentEdgeInsets %~~ { _, button in
    button.traitCollection.verticalSizeClass == .compact
      ? .init(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0)
      : .init(top: 12.0, left: 14.0, bottom: 12.0, right: 24.0)
  }

  <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: 10.0, bottom: 0, right: -10.0)
  <> UIButton.lens.image(for: .normal) %~ { _ in image(named: "fb-logo-white") }

// MARK: - Save

public func styleSaveButton(_ button: UIButton) {
  button.setTitle(nil, for: .normal)
  button.tintColor = .ksr_support_700
  button.setImage(image(named: "icon--heart-outline"), for: .normal)
  button.setImage(image(named: "icon--heart"), for: .selected)
  button.accessibilityLabel = Strings.Save_this_project()
}

// MARK: - Share

public let shareButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.image(for: .normal) .~ image(named: "icon--share")
    <> UIButton.lens.tintColor .~ .ksr_support_700
    <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

// MARK: - Read More Campaign Button

public let readMoreButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_support_700
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_support_400
  <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
  <> UIButton.lens.backgroundColor .~ .ksr_white
  <> UIButton.lens.contentEdgeInsets .~ .zero

// experimental campaign button
public let greyReadMoreButtonStyle = greyButtonStyle
  <> UIButton.lens.contentHorizontalAlignment .~ .center
