import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.font .~ .ksr_body()

public let settingsTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_600
    <> UILabel.lens.font .~ .ksr_subhead()

public let settingsLogoutButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
  <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.profile_settings_log_out_button() }

public let settingsEmailIconButton =
  UIButton.lens.title(forState: .Normal) .~ nil
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .clearColor()
    <> UIButton.lens.tintColor .~ .ksr_text_navy_600

public let settingsPhoneIconButton =
  UIButton.lens.title(forState: .Normal) .~ nil
    <> UIButton.lens.tintColor .~ .ksr_text_navy_600
