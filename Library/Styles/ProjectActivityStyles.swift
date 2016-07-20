import Prelude
import Prelude_UIKit
import UIKit

public let projectActivityBulletSeparatorViewStyle = roundedStyle(cornerRadius: 2.0)
  <> UIView.lens.backgroundColor .~ .ksr_text_navy_500

public let projectActivityCardStyle = cardStyle()
  <> UIView.lens.layer.borderColor .~ UIColor.ksr_navy_300.CGColor

public let projectActivityDividerViewStyle = UIView.lens.backgroundColor .~ .ksr_navy_300

public let projectActivityFooterButton = UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_green_700
  <> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote(size: 12).bolded

public let projectActivityFooterStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: 6, leftRight: 12)
    <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.spacing .~ 14

public let projectActivityHeaderStackViewStyle = UIStackView.lens.backgroundColor .~ UIColor.ksr_navy_200
  <> UIStackView.lens.layoutMargins .~ .init(topBottom: 14, leftRight: 12)
  <> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  <> UIStackView.lens.spacing .~ 10

// Use `.ksr_body` for font.
public let projectActivityStateChangeLabelStyle = UILabel.lens.numberOfLines .~ 0
  <> UILabel.lens.textAlignment .~ .Center

// Use `.ksr_title3(size: 14)` for font.
public let projectActivityTitleLabelStyle = UILabel.lens.textColor .~ .ksr_text_navy_600
  <> UILabel.lens.numberOfLines .~ 2
