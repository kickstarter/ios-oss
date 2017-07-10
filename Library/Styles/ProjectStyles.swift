import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public func projectAttributedNameAndBlurb(_ project: Project) -> NSAttributedString {

  let isProjectNamePunctuated = project.name.unicodeScalars.last
    .map(CharacterSet.punctuationCharacters.contains)
    .coalesceWith(false)

  let projectName = isProjectNamePunctuated ? project.name : "\(project.name):"

  let baseNameAttributedString = NSMutableAttributedString(
    string: "\(projectName) ",
    attributes: [
      NSFontAttributeName: UIFont.ksr_title3(size: 18.0),
      NSForegroundColorAttributeName: UIColor.ksr_text_grey_900
    ]
  )

  let blurbAttributedString = NSAttributedString(
    string: project.blurb,
    attributes: [
      NSFontAttributeName: UIFont.ksr_title3(size: 18.0),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_600
    ]
  )

  baseNameAttributedString.append(blurbAttributedString)

  return baseNameAttributedString
}

public func projectCellBackgroundColor() -> UIColor {
  return .ksr_grey_200
}
