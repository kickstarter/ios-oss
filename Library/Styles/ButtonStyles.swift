import Prelude
import Prelude_UIKit
import UIKit

// See `Kickstarter-iOS/SharedViews/ViewModifiers/ButtonModifiers.swift` for the SwiftUI version of
// these styles. These files should be kept in sync.

// MARK: - Apple Pay

public let applePayButtonStyle: ButtonStyle = { button in
  let cornerRadius: CGFloat = featureNewDesignSystemEnabled() ? Styles.cornerRadius : Styles.grid(2)

  return button
    |> roundedStyle(cornerRadius: cornerRadius)
    |> \.isAccessibilityElement .~ true
}

// MARK: - Base

/// Applies base styling for secondary and legacy buttons (e.g., Blue, Gray).
/// If `featureNewDesignSystemEnabled()` is enabled, it applies the new corner radius and font defined in the Design System.
/// These styles are temporary for buttons that do not yet have a direct equivalent in the new system
/// and are expected to be replaced in the future.
public let baseButtonStyle: ButtonStyle = { button in
  let cornerRadius: CGFloat = featureNewDesignSystemEnabled() ? Styles.cornerRadius : Styles.grid(2)
  let font: UIFont = featureNewDesignSystemEnabled() ? .ksr_ButtonLabel() : .ksr_headline(size: 16)

  return button
    |> roundedStyle(cornerRadius: cornerRadius)
    |> UIButton.lens.contentEdgeInsets .~ .init(all: Styles.grid(2))
    |> UIButton.lens.adjustsImageWhenDisabled .~ false
    |> UIButton.lens.adjustsImageWhenHighlighted .~ false
    <> UIButton.lens.titleLabel.font .~ font
    <> UIButton.lens.titleLabel.lineBreakMode .~ NSLineBreakMode.byTruncatingMiddle
    <> UIButton.lens.titleLabel.textAlignment .~ NSTextAlignment.center
    <> UIButton.lens.titleLabel.numberOfLines .~ 1
}

// MARK: - Red

/// Applies the new `KSRButtonStyle.filledDestructive` style when `featureNewDesignSystemEnabled()` is enabled.
/// If the feature flag is disabled, it falls back to the legacy `_redButtonStyle`.
public let redButtonStyle: ButtonStyle = { button in
  if featureNewDesignSystemEnabled() {
    button.applyStyleConfiguration(KSRButtonStyle.filledDestructive)

    return button
  }

  return _redButtonStyle(button)
}

private let _redButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.ksr_alert.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.ksr_alert.uiColor().mixDarker(0.12)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ LegacyColors.ksr_alert.uiColor().mixLighter(0.36)

// MARK: - Black

/// Applies the new `KSRButtonStyle.filled` style when `featureNewDesignSystemEnabled()` is enabled.
/// If the feature flag is disabled, it falls back to the legacy `_blackButtonStyle`.
public let blackButtonStyle: ButtonStyle = { button in
  if featureNewDesignSystemEnabled() {
    button.applyStyleConfiguration(KSRButtonStyle.filled)

    return button
  }

  return _blackButtonStyle(button)
}

private let _blackButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.titleColor(for: .disabled) .~ LegacyColors.ksr_support_100.uiColor()
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.ksr_support_700.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.ksr_support_700.uiColor()
  .mixDarker(0.66)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ LegacyColors.ksr_support_700.uiColor().mixLighter(0.36)
  <> UIButton.lens.backgroundColor(for: .selected) .~ LegacyColors.ksr_support_700.uiColor().mixLighter(0.46)

// MARK: - Blue

/// Applies the new `KSRButtonLegacyStyle.blue` style when `featureNewDesignSystemEnabled()` is enabled.
/// If the feature flag is disabled, it falls back to the legacy `_blueButtonStyle`.
public let blueButtonStyle: ButtonStyle = { button in
  if featureNewDesignSystemEnabled() {
    button.applyStyleConfiguration(KSRButtonLegacyStyle.blue)

    return button
  }

  return _blueButtonStyle(button)
}

private let _blueButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.Buttons.blue.uiColor()
  <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.Buttons.blue.uiColor().mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ LegacyColors.Buttons.blue.uiColor().mixLighter(0.36)

// MARK: - Green

/// Applies the new `KSRButtonStyle.green` style when `featureNewDesignSystemEnabled()` is enabled.
/// If the feature flag is disabled, it falls back to the legacy `_greenButtonStyle`.
public let greenButtonStyle: ButtonStyle = { button in
  if featureNewDesignSystemEnabled() {
    button.applyStyleConfiguration(KSRButtonStyle.green)

    return button
  }

  return _greenButtonStyle(button)
}

private let _greenButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.Background.Action.primary.uiColor()
  <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.Background.Action.Primary.pressed
  .uiColor()
  <> UIButton.lens.backgroundColor(for: .disabled) .~ LegacyColors.Background.Action.Primary.disabled
  .uiColor()

// MARK: - Grey

/// Applies the new `KSRButtonLegacyStyle.grey` style when `featureNewDesignSystemEnabled()` is enabled.
/// If the feature flag is disabled, it falls back to the legacy `_greyButtonStyle`.
public let greyButtonStyle: ButtonStyle = { button in
  if featureNewDesignSystemEnabled() {
    button.applyStyleConfiguration(KSRButtonLegacyStyle.grey)

    return button
  }

  return _greyButtonStyle(button)
}

private let _greyButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_support_700.uiColor()
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.ksr_support_300.uiColor()
  <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_support_700.uiColor()
  <> UIButton.lens.titleColor(for: .disabled) .~ LegacyColors.ksr_support_400.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.ksr_support_300.uiColor()
  .mixDarker(0.36)
  <> UIButton.lens.backgroundColor(for: .disabled) .~ LegacyColors.ksr_support_300.uiColor().mixLighter(0.12)

// MARK: - Facebook

/// Applies the new `KSRButtonStyle.facebook` style when `featureNewDesignSystemEnabled()` is enabled.
/// If the feature flag is disabled, it falls back to the legacy `_facebookButtonStyle`.
public let facebookButtonStyle: ButtonStyle = { button in
  if featureNewDesignSystemEnabled() {
    button.applyStyleConfiguration(KSRButtonStyle.facebook)

    button.configuration?.imagePadding = 9.0

    button.configuration?.contentInsets = button.traitCollection.verticalSizeClass == .compact ?
      NSDirectionalEdgeInsets(top: 10.0, leading: 12.0, bottom: 10.0, trailing: 12.0) :
      NSDirectionalEdgeInsets(top: 12.0, leading: 16.0, bottom: 12.0, trailing: 16.0)

    button.configuration?.image = image(named: "fb-logo-white")?.withRenderingMode(.alwaysTemplate)

    return button
  }

  return _facebookButtonStyle(button)
}

private let _facebookButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.Facebook.primary.uiColor()
  <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ LegacyColors.Facebook.pressed.uiColor()
  <> UIButton.lens.backgroundColor(for: .disabled) .~ LegacyColors.Facebook.disabled.uiColor()
  <> UIButton.lens.tintColor .~ LegacyColors.ksr_white.uiColor()
  <> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 18.0)
  <> UIButton.lens.contentEdgeInsets %~~ { _, button in
    button.traitCollection.verticalSizeClass == .compact
      ? .init(topBottom: 10.0, leftRight: 12.0)
      : .init(topBottom: 12.0, leftRight: 16.0)
  }

  <> UIButton.lens
  .image(for: .normal) %~ { _ in image(named: "fb-logo-white")?.withRenderingMode(.alwaysTemplate) }

// MARK: - Save

public func styleSaveButton(_ button: UIButton) {
  button.setTitle(nil, for: .normal)
  button.tintColor = LegacyColors.ksr_support_700.uiColor()
  button.setImage(image(named: "icon--heart-outline"), for: .normal)
  button.setImage(image(named: "icon--heart"), for: .selected)
  button.accessibilityLabel = Strings.Save_this_project()
}

// MARK: - Share

public let shareButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.image(for: .normal) .~ image(named: "icon--share")
    <> UIButton.lens.tintColor .~ LegacyColors.ksr_support_700.uiColor()
    <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }
