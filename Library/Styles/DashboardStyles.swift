import Prelude
import Prelude_UIKit
import UIKit

public let dashboardContextCellStyle = baseTableViewCellStyle()
  <> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) %~ {
    .init(topBottom: 32.0, leftRight: $0.left)
}

public let dashboardActivityButtonStyle = UIButton.lens.titleText(forState: .Normal)
  %~ { _ in Strings.dashboard_buttons_activity() }

public let dashboardStatTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_white
    <> UILabel.lens.font .~ .ksr_headline

public let dashboardStatSubtitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_white
    <> UILabel.lens.font .~ .ksr_subhead

public let lastUpdatePublishedAtLabelStyle =
  UILabel.lens.font .~ .ksr_caption1
    <> UILabel.lens.textColor .~ .ksr_darkGrayText

public let dashboardMessagesButtonStyle = UIButton.lens.titleText(forState: .Normal)
  %~ { _ in  Strings.dashboard_buttons_messages() }

public let postUpdateButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in  Strings.dashboard_buttons_post_update() }

public let dashboardShareButtonStyle = neutralButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_buttons_share() }
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 12.0, leftRight: 32.0)

public let dashboardVideoCompletionPercentageLabelStyle =
  UILabel.lens.textColor .~ .ksr_darkGrayText
  <> UILabel.lens.font .~ UIFont.ksr_subhead.italicized

public let dashboardVideoExternalPlayCountLabelStyle =
  UILabel.lens.textColor .~ .ksr_darkGrayText
    <> UILabel.lens.font .~ .ksr_body

public let dashboardVideoInternalPlayCountLabelStyle =
  UILabel.lens.textColor .~ .ksr_green
    <> UILabel.lens.font .~ .ksr_body

public let dashboardVideoPlaysTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_darkGrayText
  <> UILabel.lens.font .~ .ksr_headline
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_video_title() }

public let dashboardVideoTotalPlaysCountLabelStyle =
  UILabel.lens.textColor .~ .ksr_black
    <> UILabel.lens.font .~ UIFont.ksr_title1.bolded
