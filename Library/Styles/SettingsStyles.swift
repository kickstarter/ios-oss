import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public let settingsSectionButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil

public let settingsSectionLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_dark_grey_500
    <> UILabel.lens.font .~ .ksr_subhead()
    <> UILabel.lens.numberOfLines .~ 2

public let settingsTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_dark_grey_900
    <> UILabel.lens.font .~ .ksr_subhead()

public let settingsLogoutButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.profile_settings_log_out_button() }

public let settingsNotificationIconButtonStyle =
  UIButton.lens.title(for: .normal) .~ nil
    <> UIButton.lens.tintColor .~ .ksr_text_dark_grey_400

public let notificationButtonStyle = UIButton.lens.layer.cornerRadius .~ 9
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_300.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.backgroundColor(for: .normal) .~ .white
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_grey_200
  <> UIButton.lens.backgroundColor(for: .selected) .~ .ksr_grey_200
  <> UIButton.lens.title(for: .normal) .~ nil
  <> UIButton.lens.clipsToBounds .~ true
