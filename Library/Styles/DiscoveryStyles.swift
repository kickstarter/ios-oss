import KsApi
import Prelude
import Prelude_UIKit
import UIKit

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

public func discoveryPagerSortButtonStyle <B: UIButtonProtocol> (sort sort: DiscoveryParams.Sort)
  -> (B -> B) {

    let sortString = string(forSort: sort)

    return
      B.lens.titleColor(forState: .Normal) .~ UIColor.ksr_text_navy_700
        <> B.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_500
        <> B.lens.titleLabel.font .~ .ksr_subhead()
        <> B.lens.accessibilityLabel %~ { _ in
          Strings.discovery_accessibility_buttons_sort_label(sort: sortString)
        }
        <> B.lens.accessibilityHint %~ { _ in Strings.discovery_accessibility_buttons_sort_hint() }
        <> B.lens.contentEdgeInsets .~ .init(topBottom: 0.0, leftRight: 16.0)
        <> B.lens.title(forState: .Normal) .~ sortString
}

public let discoveryProjectCellStyle =
  baseTableViewCellStyle()
    <> UITableViewCell.lens.accessibilityHint .~ Strings.dashboard_tout_accessibility_hint_opens_project()

private func string(forSort sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .EndingSoon:
    return Strings.discovery_sort_types_end_date()
  case .Magic:
    return Strings.discovery_sort_types_magic()
  case .MostFunded:
    return Strings.discovery_sort_types_most_funded()
  case .Newest:
    return Strings.discovery_sort_types_newest()
  case .Popular:
    return Strings.discovery_sort_types_popularity()
  }
}
