import Prelude
import Prelude_UIKit
import UIKit

public let deprecatedAuthorBadgeLabelStyle =
  UILabel.lens.font .~ .ksr_headline(size: 14.0)

public let deprecatedAuthorBadgeViewStyle =
  UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.grid(1))
