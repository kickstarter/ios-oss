import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public func projectAttributedNameAndBlurb(project: Project) -> NSAttributedString {
  let isProjectNamePunctuated = project.name.utf16.last
    .map { NSCharacterSet.punctuationCharacterSet().characterIsMember($0) } ?? false

  let projectName = isProjectNamePunctuated ? project.name : "\(project.name)."

  let baseNameAttributedString = NSMutableAttributedString(
    string: "\(projectName) ",
    attributes: [
      NSFontAttributeName: UIFont.ksr_title3(size: 18.0),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
    ]
  )

  let blurbAttributedString = NSAttributedString(
    string: project.blurb,
    attributes: [
      NSFontAttributeName: UIFont.ksr_title3(size: 18.0),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_600
    ]
  )

  baseNameAttributedString.appendAttributedString(blurbAttributedString)

  return baseNameAttributedString
}

public let projectStatTitleStyle =
  UILabel.lens.font .~ UIFont.ksr_title2().bolded
    <> UILabel.lens.textColor .~ .ksr_text_navy_700

public let projectStatSubtitleStyle =
  UILabel.lens.font .~ .ksr_caption1(size: 13)
    <> UILabel.lens.textColor .~ .ksr_text_navy_600

public let subpageTabButtonStyle =
  UIButton.lens.titleLabel.font .~ UIFont.ksr_headline(size: 14)
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_500
    <> UIButton.lens.titleColor(forState: .Selected) .~ .ksr_text_navy_700
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_green_700
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: Styles.grid(3), leftRight: 0)
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_300
    <> UIButton.lens.adjustsImageWhenHighlighted .~ false

public let contactCreatorButtonStyle =
  borderButtonStyle
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .ksr_navy_200
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_navy_400
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_500
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_text_navy_700
    <> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 13)
    <> UIButton.lens.layer.borderColor .~ UIColor.ksr_grey_400.CGColor
    <> UIButton.lens.adjustsImageWhenHighlighted .~ true
    <> UIButton.lens.tintColor .~ .ksr_text_navy_500
    <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: Styles.grid(2), bottom: 0, right: 0)
    <> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Ask_me_anything() }

public let categoryLocationButtonStyle =
  borderButtonStyle
    <> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 10, leftRight: 12)
    <> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
    <> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_200
    <> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_navy_500
    <> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_navy_700
    <> UIButton.lens.adjustsImageWhenHighlighted .~ true
    <> UIButton.lens.tintColor .~ .ksr_text_navy_500
    <> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: Styles.grid(1), bottom: 0, right: -Styles.grid(1))
    <> (UIButton.lens.contentEdgeInsets • UIEdgeInsets.lens.right) %~ { $0 + Styles.grid(1) }
    <> UIButton.lens.layer.cornerRadius .~ Styles.grid(3)
