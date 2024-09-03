import Library
import UIKit

public enum PledgeViewStyles {
  public static func pledgeAmountHeadingStyle(_ label: UILabel) {
    label.accessibilityTraits = UIAccessibilityTraits.header
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.ksr_headline(size: 16).bolded
    label.numberOfLines = 0
  }

  public static func pledgeAmountValueStyle(_ label: UILabel) {
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = NSTextAlignment.right
    label.isAccessibilityElement = true
    label.minimumScaleFactor = 0.75
  }

  public static func pledgeAmountStackViewStyle(_ stackView: UIStackView) {
    stackView.backgroundColor = .ksr_white
    stackView.layoutMargins = UIEdgeInsets(leftRight: Styles.gridHalf(4))
  }

  public static func rootPledgeCTAStackViewStyle(_ stackView: UIStackView) {
    stackView.axis = NSLayoutConstraint.Axis.vertical
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets.init(
      top: Styles.grid(2),
      left: Styles.grid(3),
      bottom: Styles.grid(0),
      right: Styles.grid(3)
    )
    stackView.spacing = Styles.grid(1)
  }
}
