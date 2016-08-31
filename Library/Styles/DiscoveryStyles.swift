import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public enum CategoryGroup {
  case none
  case culture
  case entertainment
  case story

  public init(categoryId: Int?) {
    let category = RootCategory(categoryId: categoryId ?? RootCategory.unrecognized.rawValue)
    switch category {
    case .art, .crafts, .design, .fashion, .theater:
      self = .culture
    case .dance, .food, .games, .music, .tech:
    self = .entertainment
    case .comics, .film, .journalism, .photography, .publishing:
      self = .story
    case .unrecognized:
      self = .none
    }
  }
}

public func discoveryPrimaryColor(forCategoryId id: Int?) -> UIColor {
  let group = CategoryGroup(categoryId: id)
  switch group {
  case .none:
    return .ksr_navy_700
  case .culture:
    return .ksr_red_400
  case .entertainment:
    return .ksr_violet_500
  case .story:
    return .ksr_forest_700
  }
}

public func discoverySecondaryColor(forCategoryId id: Int?) -> UIColor {
  let group = CategoryGroup(categoryId: id)
  switch group {
  case .none:
    return .ksr_green_700
  case .culture:
    return .ksr_violet_600
  case .entertainment:
    return .ksr_magenta_400
  case .story:
    return .ksr_forest_500
  }
}

public func discoveryGradientColors(forCategoryId id: Int?) -> (UIColor, UIColor) {
  let group = CategoryGroup(categoryId: id)
  switch group {
  case .none:
    return (.whiteColor(), .whiteColor())
  case .culture:
    return (.ksr_peachToBlushGradientStart, .ksr_peachToBlushGradientEnd)
  case .entertainment:
    return (.ksr_lavenderToPowderGradientStart, .ksr_lavenderToPowderGradientEnd)
  case .story:
    return (.ksr_sandToSageGradientStart, .ksr_sandToSageGradientEnd)
  }
}

public let discoveryBorderLineStyle = UIView.lens.alpha .~ 0.15

public let discoveryNavDividerLabelStyle =
  UILabel.lens.font .~ UIFont.ksr_callout()
    <> UILabel.lens.alpha .~ 0.6

public let discoveryNavTitleStackViewStyle =
  UIStackView.lens.layoutMargins %~~ { _, stack in
    stack.traitCollection.horizontalSizeClass == .Compact ? .init(top: -6.0) : .init(top: 0.0)
    }
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

public let discoveryOnboardingSignUpButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_900
  <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
  <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
  <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_200
  <> UIButton.lens.layer.borderColor .~ UIColor.blackColor().CGColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.discovery_onboarding_buttons_signup_or_login()
}

public func discoveryFilterLabelStyle<L: UILabelProtocol> (categoryId categoryId: Int?, isSelected: Bool)
  -> (L -> L) {
  return
    L.lens.font .~ isSelected ? UIFont.ksr_title1(size: 22).bolded : .ksr_title1(size: 22)
      <> L.lens.textColor .~ discoveryPrimaryColor(forCategoryId: categoryId)
      <> L.lens.alpha .~ (categoryId == nil) ? 1.0 : (isSelected ? 1.0 : 0.6)
}

public let discoveryOnboardingTitleStyle =
  UILabel.lens.font .~ .ksr_title3()
    <> UILabel.lens.textAlignment .~ .Center
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.text %~ { _ in Strings.discovery_onboarding_title_bring_creative_projects_to_life() }

public let discoveryOnboardingLogoStyle =
  UIImageView.lens.contentMode .~ .ScaleAspectFit
    <> UIImageView.lens.contentHuggingPriorityForAxis(.Vertical) .~ UILayoutPriorityRequired
    <> UIImageView.lens.contentCompressionResistancePriorityForAxis(.Vertical) .~ UILayoutPriorityRequired

public let discoveryOnboardingStackViewStyle =
  UIStackView.lens.spacing .~ 16.0
    <> UIStackView.lens.distribution .~ .Fill
    <> UIStackView.lens.alignment .~ .Fill

public let discoveryOnboardingCellStyle = baseTableViewCellStyle()
  <> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) %~ {
    .init(topBottom: 48.0, leftRight: $0.left)
}

public let discoveryProjectCellStyle =
  baseTableViewCellStyle()
    <> UITableViewCell.lens.accessibilityHint %~ { _ in
      Strings.dashboard_tout_accessibility_hint_opens_project()
}

public func discoverySortPagerButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort,
                                                                 categoryId: Int?,
                                                                 isLeftMost: Bool,
                                                                 isRightMost: Bool) -> (B -> B) {

  let sortString = string(forSort: sort)
  let titleColor = discoverySecondaryColor(forCategoryId: categoryId)

  let normalTitleString = NSAttributedString(string: sortString, attributes: [
    NSFontAttributeName: UIFont.ksr_subhead(size: 14.0),
    NSForegroundColorAttributeName: titleColor.colorWithAlphaComponent(0.6)
  ])

  let selectedTitleString = NSAttributedString(string: sortString, attributes: [
    NSFontAttributeName: UIFont.ksr_subhead(size: 14.0).bolded,
    NSForegroundColorAttributeName: titleColor
  ])

  return
    B.lens.titleColor(forState: .Highlighted) .~ titleColor
      <> B.lens.accessibilityLabel %~ { _ in
        Strings.discovery_accessibility_buttons_sort_label(sort: sortString)
      }
      <> B.lens.accessibilityHint %~ { _ in Strings.discovery_accessibility_buttons_sort_hint() }
      <> B.lens.contentEdgeInsets .~ sortButtonEdgeInsets(isLeftMost: isLeftMost,
                                                          isRightMost: isRightMost)
      <> B.lens.attributedTitle(forState: .Normal) %~ { _ in normalTitleString }
      <> B.lens.attributedTitle(forState: .Selected) %~ { _ in selectedTitleString }
}

public let postcardMetadataLabelStyle =
  UILabel.lens.font .~ .ksr_headline(size: 12.0)
    <> UILabel.lens.textColor .~ .ksr_text_navy_700

public let postcardMetadataStackViewStyle =
  UIStackView.lens.alignment .~ .Center
    <> UIStackView.lens.spacing .~ Styles.grid(1)
    <> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: 8.0)
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

public let postcardNameAndBlurbStyle =
  SimpleHTMLLabel.lens.baseFont .~ .ksr_title3(size: 18.0)
    <> SimpleHTMLLabel.lens.baseColor .~ .ksr_text_navy_600
    <> SimpleHTMLLabel.lens.boldFont .~ .ksr_title3(size: 18.0)
    <> SimpleHTMLLabel.lens.boldColor .~ .ksr_text_navy_700
    <> SimpleHTMLLabel.lens.numberOfLines .~ 3
    <> SimpleHTMLLabel.lens.lineBreakMode .~ .ByTruncatingTail

public let postcardSocialStackViewStyle =
  UIStackView.lens.alignment .~ .Center
    <> UIStackView.lens.spacing .~ Styles.grid(1)
    <> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: 8.0)
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

public let postcardStatsSubtitleStyle =
  UILabel.lens.font .~ .ksr_caption1()
    <> UILabel.lens.textColor .~ .ksr_text_navy_500

public let postcardStatsTitleStyle =
  UILabel.lens.font .~ .ksr_headline(size: 12.0)

private func sortButtonEdgeInsets(isLeftMost isLeftMost: Bool, isRightMost: Bool) -> UIEdgeInsets {

  let edge = Styles.grid(2)
  let inner = Styles.grid(4) - 3

  return UIEdgeInsets(
    top: 0,
    left: isLeftMost ? edge : inner,
    bottom: 0,
    right: isRightMost ? edge : inner
  )
}

private func string(forSort sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon:
    return Strings.ending_soon()
  case .Magic:
    return Strings.home()
  case .MostFunded:
    return Strings.discovery_sort_types_most_funded()
  case .Newest:
    return Strings.discovery_sort_types_newest()
  case .Popular:
    return Strings.popular()
  }
}
