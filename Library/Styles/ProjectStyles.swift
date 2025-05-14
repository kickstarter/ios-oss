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
      NSAttributedString.Key.font: UIFont.ksr_title3(size: 18.0),
      NSAttributedString.Key.foregroundColor: LegacyColors.ksr_support_700.uiColor()
    ]
  )

  let blurbAttributedString = NSAttributedString(
    string: project.blurb,
    attributes: [
      NSAttributedString.Key.font: UIFont.ksr_title3(size: 18.0),
      NSAttributedString.Key.foregroundColor: LegacyColors.ksr_support_400.uiColor()
    ]
  )

  baseNameAttributedString.append(blurbAttributedString)

  return baseNameAttributedString
}

public func projectCellBackgroundColor() -> UIColor {
  return LegacyColors.ksr_white.uiColor()
}
