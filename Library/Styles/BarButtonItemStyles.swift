import Prelude
import Prelude_UIKit
import UIKit

internal let baseBarButtonItemStyle = UIBarButtonItem.lens.tintColor .~ .ksr_navy_600

public let shareBarButtonItemStyle = baseBarButtonItemStyle
  <> UIBarButtonItem.lens.image .~ UIImage(named: "share-icon")
  <> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }
