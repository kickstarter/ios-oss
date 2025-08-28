import KDS
import Prelude
import Prelude_UIKit
import UIKit

// See `Kickstarter-iOS/SharedViews/ViewModifiers/ButtonModifiers.swift` for the SwiftUI version of
// these styles. These files should be kept in sync.

// MARK: - Apple Pay

public let applePayButtonStyle: ButtonStyle = { button in
  let cornerRadius: CGFloat = Dimension.CornerRadius.small

  return button
    |> roundedStyle(cornerRadius: cornerRadius)
    |> \.isAccessibilityElement .~ true
}

// MARK: - Red

/// Applies the new `KSRButtonStyle.filledDestructive` style.
public let redButtonStyle: ButtonStyle = { button in
  button.applyStyleConfiguration(KSRButtonStyle.filledDestructive)

  return button
}

// MARK: - Black

/// Applies the new `KSRButtonStyle.filled` style.
public let blackButtonStyle: ButtonStyle = { button in
  button.applyStyleConfiguration(KSRButtonStyle.filled)
  return button
}

// MARK: - Blue

/// Applies the new `KSRButtonLegacyStyle.blue` style.
public let blueButtonStyle: ButtonStyle = { button in
  button.applyStyleConfiguration(KSRButtonLegacyStyle.blue)
  return button
}

// MARK: - Green

/// Applies the new `KSRButtonStyle.green` style.
public let greenButtonStyle: ButtonStyle = { button in
  button.applyStyleConfiguration(KSRButtonStyle.green)
  return button
}

// MARK: - Grey

/// Applies the new `KSRButtonLegacyStyle.grey` style.
public let greyButtonStyle: ButtonStyle = { button in
  button.applyStyleConfiguration(KSRButtonLegacyStyle.grey)
  return button
}

/// Applies base styling for secondary and legacy buttons (e.g., Blue, Gray).
/// These styles are temporary for buttons that do not yet have a direct equivalent in the new system
/// and are expected to be replaced in the future.
public let baseButtonStyle: ButtonStyle = { button in
  let cornerRadius: CGFloat = Dimension.CornerRadius.small
  let font: UIFont = .ksr_ButtonLabel()

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

// MARK: - Facebook

/// Applies the new `KSRButtonStyle.facebook` style.
public let facebookButtonStyle: ButtonStyle = { button in
  button.applyStyleConfiguration(KSRButtonStyle.facebook)

  button.configuration?.imagePadding = 9.0

  button.configuration?.contentInsets = button.traitCollection.verticalSizeClass == .compact ?
    NSDirectionalEdgeInsets(top: 10.0, leading: 12.0, bottom: 10.0, trailing: 12.0) :
    NSDirectionalEdgeInsets(top: 12.0, leading: 16.0, bottom: 12.0, trailing: 16.0)

  button.configuration?.image = image(named: "fb-logo-white")?.withRenderingMode(.alwaysTemplate)

  return button
}

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
