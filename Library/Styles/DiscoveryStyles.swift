import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public func discoveryPrimaryColor() -> UIColor {
  return .ksr_dark_grey_900
}

public func discoverySecondaryColor() -> UIColor {
  return .ksr_text_dark_grey_500
}

public let discoveryBorderLineStyle = UIView.lens.alpha .~ 0.15

public let discoveryNavDividerLabelStyle =
  UILabel.lens.font .~ UIFont.ksr_callout()
    <> UILabel.lens.alpha .~ 0.6

public let discoveryNavTitleStackViewStyle =
  UIStackView.lens.layoutMargins %~~ { _, stack in
    stack.traitCollection.horizontalSizeClass == .compact ? .init(top: -6.0) : .init(top: 0.0)
    }
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let discoverySaveButtonStyle = saveButtonStyle
  <> UIButton.lens.image(for: .normal) .~ image(named: "icon--heart-outline-circle")
  <> UIButton.lens.image(for: .selected) .~ image(named: "icon--heart-circle")
  <> UIButton.lens.tintColor .~ .white

public let discoveryOnboardingSignUpButtonStyle = baseButtonStyle
  <> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_900
  <> UIButton.lens.backgroundColor(for: .normal) .~ .white
  <> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_text_dark_grey_400
  <> UIButton.lens.backgroundColor(for: .highlighted) .~ .ksr_navy_200
  <> UIButton.lens.layer.borderColor .~ UIColor.ksr_dark_grey_900.cgColor
  <> UIButton.lens.layer.borderWidth .~ 1.0
  <> UIButton.lens.title(for: .normal) %~ { _ in
    Strings.discovery_onboarding_buttons_signup_or_login()
}

public func discoveryFilterLabelFontStyle<L: UILabelProtocol> (isSelected: Bool) -> ((L) -> L) {
  return L.lens.font %~~ { _, label in
    label.traitCollection.isRegularRegular
      ? isSelected ? UIFont.ksr_title1(size: 24).bolded : .ksr_title1(size: 24)
      : isSelected ? UIFont.ksr_title1(size: 22).bolded : .ksr_title1(size: 22)
  }
}

public func discoveryFilterLabelStyle<L: UILabelProtocol> (categoryId: Int?, isSelected: Bool)
  -> ((L) -> L) {
  return L.lens.textColor .~ discoveryPrimaryColor()
      <> L.lens.alpha .~ ((categoryId == nil) ? 1.0 : (isSelected ? 1.0 : 0.8))
}

public let discoveryFilterRowMarginStyle = baseTableViewCellStyle()
  <> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
    cell.traitCollection.isRegularRegular
      ? .init(top: Styles.grid(2),
                   left: Styles.grid(6),
                   bottom: Styles.grid(2),
                   right: Styles.grid(2))
      : .init(top: Styles.grid(2),
                 left: Styles.grid(4),
                 bottom: Styles.grid(2),
                 right: Styles.grid(2))
}

public let discoveryOnboardingTitleStyle =
  UILabel.lens.font .~ .ksr_title3()
    <> UILabel.lens.textAlignment .~ .center
    <> UILabel.lens.numberOfLines .~ 2
    <> UILabel.lens.text %~ { _ in Strings.discovery_onboarding_title_bring_creative_projects_to_life() }

public let discoveryOnboardingLogoStyle =
  UIImageView.lens.contentMode .~ .scaleAspectFit
    <> UIImageView.lens.contentHuggingPriority(for: .vertical) .~ .required
    <> UIImageView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

public let discoveryOnboardingStackViewStyle =
  UIStackView.lens.spacing .~ 16.0
    <> UIStackView.lens.distribution .~ .fill
    <> UIStackView.lens.alignment .~ .fill

public let discoveryProjectCellStyle =
  baseTableViewCellStyle()
    <> UITableViewCell.lens.accessibilityHint %~ { _ in
      Strings.dashboard_tout_accessibility_hint_opens_project()
}

public func discoverySortPagerButtonStyle <B: UIButtonProtocol> (sort: DiscoveryParams.Sort,
                                                                 categoryId: Int?,
                                                                 isLeftMost: Bool,
                                                                 isRightMost: Bool,
                                                                 isRegularRegular: Bool) -> ((B) -> B) {

  let sortString = string(forSort: sort)

  let normalTitleString = NSAttributedString(string: sortString, attributes: [
    NSAttributedStringKey.font: isRegularRegular
      ? UIFont.ksr_subhead(size: 16.0)
      : UIFont.ksr_subhead(size: 15.0),
    NSAttributedStringKey.foregroundColor: discoverySecondaryColor().withAlphaComponent(0.6)
  ])

  let selectedTitleString = NSAttributedString(string: sortString, attributes: [
    NSAttributedStringKey.font: isRegularRegular
      ? UIFont.ksr_subhead(size: 16.0).bolded
      : UIFont.ksr_subhead(size: 15.0),
    NSAttributedStringKey.foregroundColor: UIColor.black
  ])

  return
    B.lens.titleColor(for: .highlighted) .~ discoverySecondaryColor()
      <> B.lens.accessibilityLabel %~ { _ in
        Strings.discovery_accessibility_buttons_sort_label(sort: sortString)
      }
      <> B.lens.accessibilityHint %~ { _ in Strings.discovery_accessibility_buttons_sort_hint() }
      <> B.lens.contentEdgeInsets .~ sortButtonEdgeInsets(isLeftMost: isLeftMost,
                                                          isRightMost: isRightMost)
      <> B.lens.attributedTitle(for: .normal) %~ { _ in normalTitleString }
      <> B.lens.attributedTitle(for: .selected) %~ { _ in selectedTitleString }
}

public let postcardMetadataLabelStyle =
  UILabel.lens.font .~ .ksr_headline(size: 12.0)
    <> UILabel.lens.textColor .~ .ksr_text_dark_grey_500

public let postcardMetadataStackViewStyle =
  UIStackView.lens.alignment .~ .center
    <> UIStackView.lens.spacing .~ Styles.grid(1)
    <> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: 8.0)
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let postcardSocialStackViewStyle =
  UIStackView.lens.alignment .~ .center
    <> UIStackView.lens.spacing .~ Styles.grid(1)
    <> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: 8.0)
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

public let postcardStatsSubtitleStyle =
  UILabel.lens.font %~~ { _, label in
      label.traitCollection.isRegularRegular
        ? .ksr_body(size: 14)
        : .ksr_body(size: 13)
    }

public let postcardStatsTitleStyle =
  UILabel.lens.font %~~ { _, label in
    label.traitCollection.isRegularRegular
      ? .ksr_headline(size: 17)
      : .ksr_headline(size: 13)
  }

private func sortButtonEdgeInsets(isLeftMost: Bool, isRightMost: Bool) -> UIEdgeInsets {

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
  case .endingSoon:
    return Strings.Ending_soon()
  case .magic:
    return Strings.discovery_sort_types_magic()
  case .mostFunded:
    return Strings.discovery_sort_types_most_funded()
  case .newest:
    return Strings.discovery_sort_types_newest()
  case .popular:
    return Strings.Popular()
  }
}
