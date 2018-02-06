import Prelude
import Prelude_UIKit
import UIKit

public let baseBarButtonItemStyle =
  UIBarButtonItem.lens.tintColor .~ .ksr_dark_grey_500

public let plainBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.style .~ .plain
  <> UIBarButtonItem.lens.titleTextAttributes(for: .normal) .~ [
    NSFontAttributeName: UIFont.ksr_subhead(size: 15)
]

public let doneBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.style .~ .done
  <> UIBarButtonItem.lens.title %~ { _ in Strings.Done() }
  <> UIBarButtonItem.lens.titleTextAttributes(for: .normal) .~ [
    NSFontAttributeName: UIFont.ksr_headline(size: 15)
]

public let iconBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.title .~ nil

public let closeBarButtonItemStyle = iconBarButtonItemStyle
  <> UIBarButtonItem.lens.image .~ image(named: "icon--cross")

public let shareBarButtonItemStyle = iconBarButtonItemStyle
  <> UIBarButtonItem.lens.image .~ image(named: "icon--share")
  <> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }
