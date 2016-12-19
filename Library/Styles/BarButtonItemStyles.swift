import Prelude
import Prelude_UIKit
import UIKit

public let baseBarButtonItemStyle =
  UIBarButtonItem.lens.tintColor .~ .ksr_navy_700

public let plainBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.style .~ .plain
  <> UIBarButtonItem.lens.titleTextAttributes(forState: .normal) .~ [
    NSFontAttributeName: UIFont.ksr_subhead(size: 15)
]

public let doneBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.style .~ .done
  <> UIBarButtonItem.lens.title %~ { _ in Strings.Done() }
  <> UIBarButtonItem.lens.titleTextAttributes(forState: .normal) .~ [
    NSFontAttributeName: UIFont.ksr_headline(size: 15)
]

public let iconBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.title .~ nil

public let closeBarButtonItemStyle = iconBarButtonItemStyle
  <> UIBarButtonItem.lens.image .~ image(named: "close-icon")

public let shareBarButtonItemStyle = iconBarButtonItemStyle
  <> UIBarButtonItem.lens.image .~ image(named: "share-icon")
  <> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }
