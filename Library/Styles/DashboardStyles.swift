import Prelude
import Prelude_UIKit
import UIKit

public let dashboardActionButtonStyle = UIButton.lens.titleLabel.font .~ .ksr_subhead()
  <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_support_400.uiColor()
  <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_support_400.uiColor()

public let dashboardActivityButtonStyle =
  dashboardActionButtonStyle
    <> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_buttons_activity() }
    <> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_activity_hint() }
    <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_buttons_activity() }

public let dashboardCellTitleLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
    <> UILabel.lens.font .~ .ksr_title2()

public let dashboardCardStyle: (UIView) -> UIView = { view in
  view
    |> UIView.lens.layer.borderColor .~ LegacyColors.ksr_support_300.uiColor().cgColor
    |> UIView.lens.layer.borderWidth .~ 1.0
}

public let dashboardChartCardViewStyle = dashboardCardStyle
  <> UIView.lens.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
  <> UIView.lens.layoutMargins .~ .init(topBottom: 24.0, leftRight: 0.0)

public let dashboardColumnTitleButtonStyle =
  UIButton.lens.titleLabel.font .~ UIFont.ksr_caption1().bolded
    <> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_support_400.uiColor()
    <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_support_100.uiColor()
    <> UIButton.lens.contentEdgeInsets .~
    .init(top: Styles.grid(2), left: 0, bottom: Styles.grid(1), right: 0)
    <> UIButton.lens.contentHorizontalAlignment .~ .left

public let dashboardColumnTextLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.font .~ .ksr_caption1()

public let dashboardContextCellStyle: (UITableViewCell) -> UITableViewCell = { cell in
  cell
    |> baseTableViewCellStyle()
    |> (UITableViewCell.lens.contentView .. UIView.lens.layoutMargins) %~ {
      .init(topBottom: 32.0, leftRight: $0.left)
    }
}

public let dashboardDrawerProjectNameTextLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.font .~ .ksr_caption1()

public let dashboardDrawerProjectNumberTextLabelStyle = dashboardColumnTextLabelStyle
  <> UILabel.lens.font .~ UIFont.ksr_caption1().bolded

public let dashboardFundingGraphAxisSeparatorViewStyle =
  UIView.lens.backgroundColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UIView.lens.accessibilityElementsHidden .~ true

public let dashboardFundingGraphXAxisLabelStyle =
  UILabel.lens.font .~ UIFont.ksr_caption1().bolded
    <> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.accessibilityElementsHidden .~ true

public let dashboardFundingGraphXAxisStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 8.0, leftRight: 16.0)
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let dashboardFundingGraphYAxisLabelStyle =
  UILabel.lens.font .~ .ksr_caption2()
    <> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

public let dashboardFundingProgressTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_funding_title_funding_progress() }

public let dashboardFundingStatsStackView =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 24.0, leftRight: 16.0)
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.distribution .~ .equalSpacing

public let dashboardStatTitleLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
    <> UILabel.lens.font .~ UIFont.ksr_body().bolded

public let dashboardStatSubtitleLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.font .~ .ksr_caption1()

public let dashboardMessagesButtonStyle =
  dashboardActionButtonStyle
    <> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_buttons_messages() }
    <> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_messages_hint() }
    <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_buttons_messages() }

public let dashboardLastUpdatePublishedAtLabelStyle =
  UILabel.lens.font .~ .ksr_caption1()
    <> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.accessibilityElementsHidden .~ true

public let dashboardReferrersPledgePercentLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.font .~ .ksr_footnote()

public let dashboardReferrersShowMoreButtonStyle = greenButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.dashboard_graphs_referrers_view_more_referrer_stats()
  }

public let dashboardReferrersSourceLabelStyle = dashboardColumnTextLabelStyle
  <> UILabel.lens.font .~ .ksr_headline(size: 14)
  <> UILabel.lens.numberOfLines .~ 0

public let dashboardReferrersTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_referrers_title_referrers() }

public let postUpdateButtonStyle = blackButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.dashboard_buttons_post_update() }
  <> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_post_update_hint() }
  <> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_buttons_post_update() }

public let dashboardRewardTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_rewards_title_rewards() }

public let dashboardReferrersCumulativeStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(4))
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let dashboardStatsRowStackViewStyle =
  UIStackView.lens.axis .~ .horizontal
    <> UIStackView.lens.alignment .~ .fill
    <> UIStackView.lens.distribution .~ .fillEqually
    <> UIStackView.lens.spacing .~ 15
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let dashboardTitleViewTextDisabledStyle =
  UILabel.lens.font %~~ { _, label in
    label.traitCollection.isRegularRegular
      ? UIFont.ksr_body(size: 18)
      : UIFont.ksr_callout()
  }

public let dashboardTitleViewTextEnabledStyle =
  UILabel.lens.font %~~ { _, label in
    label.traitCollection.isRegularRegular
      ? UIFont.ksr_body(size: 18).bolded
      : UIFont.ksr_callout().bolded
  }

public let dashboardVideoCompletionPercentageLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.font .~ UIFont.ksr_caption1()

public let dashboardVideoExternalPlaysProgressViewStyle =
  UIView.lens.backgroundColor .~ LegacyColors.ksr_celebrate_500.uiColor()
    <> UIView.lens.layer.borderColor .~ LegacyColors.ksr_celebrate_700.uiColor().cgColor
    <> UIView.lens.layer.borderWidth .~ 1

public let dashboardVideoGraphPercentageLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_white.uiColor()
    <> UILabel.lens.font .~ UIFont.ksr_caption1().bolded

public let dashboardVideoInternalPlaysProgressViewStyle =
  UIView.lens.backgroundColor .~ LegacyColors.ksr_create_700.uiColor()
    <> UIView.lens.layer.borderColor .~ LegacyColors.ksr_create_700.uiColor().cgColor
    <> UIView.lens.layer.borderWidth .~ 1

public let dashboardVideoPlaysTitleLabelStyle = dashboardCellTitleLabelStyle
  <> UILabel.lens.text %~ { _ in Strings.dashboard_graphs_video_title_video_plays() }

public let dashboardVideoTotalPlaysCountLabelStyle =
  UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
    <> UILabel.lens.font .~ UIFont.ksr_title1().bolded

public let dashboardViewProjectButtonStyle = greyButtonStyle
  <> UIButton.lens.title(for: .normal) %~ { _ in Strings.View() }
