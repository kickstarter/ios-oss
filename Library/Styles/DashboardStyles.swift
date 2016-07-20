import Prelude
import Prelude_UIKit
import UIKit

public let dashboardActivityButtonStyle = UIButton.lens.titleText(forState: .Normal)
  %~ { _ in Strings.dashboard_buttons_activity() }

public let dashboardCellTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
  <> UILabel.lens.font .~ .ksr_title2()

public let dashboardCardStyle = roundedStyle()
  <> UIView.lens.layer.borderColor .~ UIColor.ksr_navy_300.CGColor
  <> UIView.lens.layer.borderWidth .~ 1.0

public let dashboardChartCardViewStyle = dashboardCardStyle
  <> UIView.lens.backgroundColor .~ .ksr_grey_100
  <> UIView.lens.layoutMargins .~ .init(topBottom: 24.0, leftRight: 0.0)

public let dashboardColumnTitleButtonStyle =
  UIButton.lens.titleLabel.font .~ UIFont.ksr_caption1().bolded
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_700
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_grey_100
    <> UIButton.lens.contentEdgeInsets .~ .init(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0)
    <> UIButton.lens.contentHorizontalAlignment .~ .Left

public let dashboardColumnTextLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.font .~ .ksr_caption1()

public let dashboardContextCellStyle = baseTableViewCellStyle()
  <> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) %~ {
    .init(topBottom: 32.0, leftRight: $0.left)
}

public let dashboardDrawerProjectNameTextLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_600
    <> UILabel.lens.font .~ .ksr_caption1()

public let dashboardDrawerProjectNumberTextLabelStyle = dashboardColumnTextLabelStyle
  <> UILabel.lens.font .~ UIFont.ksr_caption1().bolded

public let dashboardFundingGraphAxisSeparatorViewStyle =
  UIView.lens.backgroundColor .~ .ksr_navy_500
  <> UIView.lens.accessibilityElementsHidden .~ true

public let dashboardFundingGraphXAxisLabelStyle =
  UILabel.lens.font .~ UIFont.ksr_caption1().bolded
    <> UILabel.lens.textColor .~ .ksr_navy_700
    <> UILabel.lens.accessibilityElementsHidden .~ true

public let dashboardFundingGraphXAxisStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 8.0, leftRight: 16.0)
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

public let dashboardFundingGraphYAxisLabelStyle =
  UILabel.lens.font .~ .ksr_caption2()
    <> UILabel.lens.textColor .~ .ksr_text_navy_500

public let dashboardFundingProgressTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_funding_title_funding_progress() }

public let dashboardFundingStatsStackView =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 24.0, leftRight: 16.0)
  <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  <> UIStackView.lens.distribution .~ .EqualSpacing

public let dashboardGrayTextBorderButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_footnote()
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_600
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_grey_100
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_300.CGColor

public let dashboardGreenTextBorderButtonStyle = borderButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_footnote()
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_green_700
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_grey_100
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_navy_300.CGColor

public let dashboardStatTitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_700
    <> UILabel.lens.font .~ UIFont.ksr_body().bolded

public let dashboardStatSubtitleLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_500
    <> UILabel.lens.font .~ .ksr_caption1()

public let dashboardLastUpdatePublishedAtLabelStyle =
  UILabel.lens.font .~ .ksr_caption1()
    <> UILabel.lens.textColor .~ .ksr_text_navy_500

public let dashboardMessagesButtonStyle = UIButton.lens.titleText(forState: .Normal)
  %~ { _ in  Strings.dashboard_buttons_messages() }

public let dashboardReferrersPledgePercentLabelStyle =
  UILabel.lens.textColor .~ .ksr_text_navy_600
  <> UILabel.lens.font .~ .ksr_footnote()

public let dashboardReferrersShowMoreButtonStyle = dashboardGreenTextBorderButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.dashboard_graphs_referrers_view_more_referrer_stats()
  }

public let dashboardReferrersSourceLabelStyle = dashboardColumnTextLabelStyle
  <> UILabel.lens.font .~ .ksr_headline(size: 14)
  <> UILabel.lens.numberOfLines .~ 2

public let dashboardReferrersTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_title_referrers() }

public let postUpdateButtonStyle = greenButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_buttons_post_update() }

public let dashboardRewardTitleLabelStyle = dashboardCellTitleLabelStyle
    <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_rewards_title_rewards() }

public let dashboardRewardRowTitleButtonStyle = textOnlyButtonStyle
  <> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote().bolded
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 12.0, leftRight: 0.0)
  <> UIButton.lens.contentHorizontalAlignment .~ .Left

public let dashboardRewardSeeAllButtonStyle = textOnlyButtonStyle
  <> UIButton.lens.titleLabel.font .~ .ksr_footnote()
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 12.0, leftRight: 0.0)
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.dashboard_graphs_rewards_view_more_reward_stats()
  }
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_700

public let dashboardShareButtonStyle = neutralButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_buttons_share() }
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 12.0, leftRight: 32.0)

public let dashboardReferrersCumulativeStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: 24)
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

public let dashboardStatsRowStackViewStyle =
  UIStackView.lens.axis .~ .Horizontal
    <> UIStackView.lens.alignment .~ .Fill
    <> UIStackView.lens.distribution .~ .FillEqually
    <> UIStackView.lens.spacing .~ 15
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

public let dashboardVideoCompletionPercentageLabelStyle =
  UILabel.lens.textColor .~ .ksr_navy_500
  <> UILabel.lens.font .~ UIFont.ksr_caption1()

public let dashboardVideoExternalPlaysProgressViewStyle =
  UIView.lens.backgroundColor .~ .ksr_orange_400
    <> UIView.lens.layer.borderColor .~ UIColor.ksr_orange_600.CGColor
    <> UIView.lens.layer.borderWidth .~ 1

public let dashboardVideoGraphPercentageLabelStyle =
  UILabel.lens.textColor .~ .whiteColor()
    <> UILabel.lens.font .~ UIFont.ksr_caption1().bolded

public let dashboardVideoInternalPlaysProgressViewStyle =
  UIView.lens.backgroundColor .~ .ksr_green_500
    <> UIView.lens.layer.borderColor .~ UIColor.ksr_green_400.CGColor
    <> UIView.lens.layer.borderWidth .~ 1

public let dashboardVideoPlaysTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_video_title_video_plays() }

public let dashboardVideoTotalPlaysCountLabelStyle =
  UILabel.lens.textColor .~ .blackColor()
    <> UILabel.lens.font .~ UIFont.ksr_title1().bolded

public let dashboardViewProjectButtonStyle = dashboardGrayTextBorderButtonStyle
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_700
  <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 8, leftRight: 16)

public let updateTitleTextFieldStyle = formFieldStyle
  <> UITextField.lens.placeholder %~ { _ in Strings.dashboard_post_update_compose_placeholder_title() }
  <> UITextField.lens.returnKeyType .~ .Next

public let updateBackersOnlyButtonStyle =
  UIButton.lens.titleText(forState: .Normal) %~ { _ in Strings.dashboard_post_update_compose_public_label() }
    <> UIButton.lens.titleText(forState: .Selected)
      %~ { _ in Strings.dashboard_post_update_compose_private_label() }

public let updateAttachmentsStackViewStyle = UIStackView.lens.alignment .~ .LastBaseline
  <> UIStackView.lens.distribution .~ .EqualSpacing
  <> UIStackView.lens.layoutMargins .~ .init(all: 4.0)
  <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  <> UIStackView.lens.spacing .~ 4.0

public let updateBodyTextViewStyle = UITextView.lens.backgroundColor .~ .clearColor()
  <> UITextView.lens.font .~ .ksr_body()
  <> UITextView.lens.textColor .~ .ksr_text_navy_900
  <> UITextView.lens.textContainerInset .~ .init(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)

public let updateAddAttachmentButtonStyle =
  UIButton.lens.contentEdgeInsets .~ .init(topBottom: 12.0, leftRight: 0.0)
    <> UIButton.lens.titleText(forState: .Normal)
      %~ { _ in Strings.dashboard_post_update_compose_attachment_buttons_add_attachment() }
