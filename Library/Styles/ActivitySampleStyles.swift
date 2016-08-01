import Prelude
import Prelude_UIKit
import UIKit

public let activitySampleBackingTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.numberOfLines .~ 2

public let activitySampleFriendFollowLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.font .~ .ksr_subhead()

public let activitySampleProjectSubtitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.font .~ .ksr_subhead()

public let activitySampleProjectTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.font .~ UIFont.ksr_subhead().bolded

public let activitySampleSeeAllActivityButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 13)
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_500.CGColor
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.discovery_activity_sample_button_see_all_activity()
}

public let activitySampleTitleLabelStyle =
  UILabel.lens.font .~ .ksr_footnote()
    <> UILabel.lens.textColor .~ .ksr_text_navy_500
    <> UILabel.lens.numberOfLines .~ 1
    <> UILabel.lens.text %~ { _ in Strings.discovery_activity_sample_title_Since_your_last_visit() }
