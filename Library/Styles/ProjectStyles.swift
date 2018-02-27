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
      NSAttributedStringKey.font: UIFont.ksr_title3(size: 18.0),
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_900
    ]
  )

  let blurbAttributedString = NSAttributedString(
    string: project.blurb,
    attributes: [
      NSAttributedStringKey.font: UIFont.ksr_title3(size: 18.0),
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_400
    ]
  )

  baseNameAttributedString.append(blurbAttributedString)

  return baseNameAttributedString
}

public func projectCellBackgroundColor() -> UIColor {
  return .white
}
