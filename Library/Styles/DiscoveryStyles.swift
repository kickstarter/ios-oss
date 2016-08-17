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
    if let categoryId = categoryId {
      switch categoryId {
      case 1, 26, 7, 9, 17:
        self = .culture
      case 6, 10, 12, 14, 16:
        self = .entertainment
      case 3, 11, 13, 15, 18:
        self = .story
      default:
        self = .none
      }
    } else {
      self = .none
    }
  }
}

private func discoveryPrimaryColor(forCategoryId id: Int?) -> UIColor {
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

public func discoveryIndicatorColor(forCategoryId id: Int?) -> UIColor {
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

public func discoverySortPagerButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort,
                                                                 categoryId: Int?,
                                                                 isLeftMost: Bool,
                                                                 isRightMost: Bool) -> (B -> B) {

  let sortString = string(forSort: sort)
  let titleColor = discoveryPrimaryColor(forCategoryId: categoryId)

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

public let discoveryProjectCellStyle =
  baseTableViewCellStyle()
    <> UITableViewCell.lens.accessibilityHint %~ { _ in
      Strings.dashboard_tout_accessibility_hint_opens_project()
}

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
