import Prelude
import Prelude_UIKit
import UIKit

public let projectActivityBulletSeparatorViewStyle: (UIView) -> UIView = { view in
  view
    |> roundedStyle(cornerRadius: 2.0)
    |> UIView.lens.backgroundColor .~ LegacyColors.ksr_support_400.uiColor()
}

public let projectActivityDividerViewStyle = UIView.lens.backgroundColor .~ LegacyColors.ksr_support_300
  .uiColor()

public let projectActivityFooterButton =
  UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_create_700.uiColor()
    <> UIButton.lens.titleLabel.font .~ UIFont.ksr_footnote(size: 12).bolded
    <> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_support_100.uiColor()

public let projectActivityFooterStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.spacing .~ Styles.grid(2)

public let projectActivityHeaderStackViewStyle =
  UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))
    <> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
    <> UIStackView.lens.spacing .~ Styles.grid(1)

public let projectActivityRegularRegularLeftRight = Styles.grid(30)

public let projectActivityRegularRegularLayoutMargins: UIEdgeInsets =
  .init(topBottom: Styles.grid(4), leftRight: projectActivityRegularRegularLeftRight)

// Use `.ksr_body` for font.
public let projectActivityStateChangeLabelStyle = UILabel.lens.numberOfLines .~ 0
  <> UILabel.lens.textAlignment .~ .center

// Use `.ksr_title3(size: 14)` for font.
public let projectActivityTitleLabelStyle = UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
  <> UILabel.lens.numberOfLines .~ 2
