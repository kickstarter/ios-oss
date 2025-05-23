import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public func discoveryPrimaryColor() -> UIColor {
  return LegacyColors.ksr_support_700.uiColor()
}

public func discoverySecondaryColor() -> UIColor {
  return LegacyColors.ksr_support_400.uiColor()
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

public func styleDiscoverySaveButton(_ button: UIButton) {
  styleSaveButton(button)
  button.setImage(image(named: "icon--heart-outline-circle"), for: .normal)
  button.setImage(image(named: "icon--heart-circle"), for: .selected)
  button.tintColor = LegacyColors.ksr_white.uiColor()
}

public func discoveryFilterLabelFontStyle<L: UILabelProtocol>(isSelected: Bool) -> ((L) -> L) {
  return L.lens.font %~~ { _, label in
    label.traitCollection.isRegularRegular
      ? isSelected ? UIFont.ksr_title1(size: 24).bolded : .ksr_title1(size: 24)
      : isSelected ? UIFont.ksr_title1(size: 22).bolded : .ksr_title1(size: 22)
  }
}

public func discoveryFilterLabelStyle<L: UILabelProtocol>(categoryId: Int?, isSelected: Bool)
  -> ((L) -> L) {
  return L.lens.textColor .~ discoveryPrimaryColor()
    <> L.lens.alpha .~ ((categoryId == nil) ? 1.0 : (isSelected ? 1.0 : 0.8))
}

public let discoveryFilterRowMarginStyle: (UITableViewCell) -> UITableViewCell = { cell in
  cell |> baseTableViewCellStyle()
    |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
      cell.traitCollection.isRegularRegular
        ? .init(
          top: Styles.grid(2),
          left: Styles.grid(6),
          bottom: Styles.grid(2),
          right: Styles.grid(2)
        )
        : .init(
          top: Styles.grid(2),
          left: Styles.grid(4),
          bottom: Styles.grid(2),
          right: Styles.grid(2)
        )
    }
}

public let discoveryProjectCellStyle: (UITableViewCell) -> UITableViewCell = { cell in
  cell |>
    baseTableViewCellStyle()
    <> UITableViewCell.lens.accessibilityHint %~ { _ in
      Strings.dashboard_tout_accessibility_hint_opens_project()
    }
}

public func discoverySortPagerButtonStyle<B: UIButtonProtocol>(
  sort: DiscoveryParams.Sort,
  categoryId _: Int?,
  isLeftMost: Bool,
  isRightMost: Bool,
  isRegularRegular: Bool
) -> ((B) -> B) {
  let sortString = string(forSort: sort)

  let normalTitleString = NSAttributedString(string: sortString, attributes: [
    NSAttributedString.Key.font: isRegularRegular
      ? UIFont.ksr_subhead(size: 16.0)
      : UIFont.ksr_subhead(size: 15.0),
    NSAttributedString.Key.foregroundColor: discoverySecondaryColor().withAlphaComponent(0.6)
  ])

  let selectedTitleString = NSAttributedString(string: sortString, attributes: [
    NSAttributedString.Key.font: isRegularRegular
      ? UIFont.ksr_subhead(size: 16.0).bolded
      : UIFont.ksr_subhead(size: 15.0),
    NSAttributedString.Key.foregroundColor: LegacyColors.ksr_black.uiColor()
  ])

  return
    B.lens.titleColor(for: .highlighted) .~ discoverySecondaryColor()
      <> B.lens.accessibilityLabel %~ { _ in
        Strings.discovery_accessibility_buttons_sort_label(sort: sortString)
      }
      <> B.lens.accessibilityHint %~ { _ in Strings.discovery_accessibility_buttons_sort_hint() }
      <> B.lens.contentEdgeInsets .~ sortButtonEdgeInsets(
        isLeftMost: isLeftMost,
        isRightMost: isRightMost
      )
      <> B.lens.attributedTitle(for: .normal) %~ { _ in normalTitleString }
      <> B.lens.attributedTitle(for: .selected) %~ { _ in selectedTitleString }
}

public let postcardCategoryLabelStyle =
  UILabel.lens.font .~ .ksr_body(size: 13.0)
    <> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
    <> UILabel.lens.textAlignment .~ .left
    <> UILabel.lens.lineBreakMode .~ .byClipping
    <> UILabel.lens.backgroundColor .~ LegacyColors.ksr_white.uiColor()

public let postcardMetadataLabelStyle =
  UILabel.lens.font .~ .ksr_headline(size: 12.0)
    <> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

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

  <> UILabel.lens.backgroundColor .~ LegacyColors.ksr_white.uiColor()

public let postcardStatsTitleStyle =
  UILabel.lens.font %~~ { _, label in
    label.traitCollection.isRegularRegular
      ? .ksr_headline(size: 17)
      : .ksr_headline(size: 13)
  }

  <> UILabel.lens.backgroundColor .~ LegacyColors.ksr_white.uiColor()

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
  case .newest:
    return Strings.discovery_sort_types_newest()
  case .popular:
    return Strings.Popular()
  case .most_backed:
    assert(
      false,
      "most_backed was added for GraphQL compatibililty. It shouldn't actually be used in V1 Discover."
    )
    return Strings.discovery_sort_types_most_backed()
  case .most_funded:
    assert(
      false,
      "most_funded was added for GraphQL compatibililty. It shouldn't actually be used in V1 Discover."
    )
    return Strings.discovery_sort_types_most_funded()
  }
}
