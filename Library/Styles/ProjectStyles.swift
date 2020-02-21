import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public enum ProjectCampaignButtonStyleType: Equatable {
  case controlReadMoreButton
  case experimentalReadMoreButton

  public var style: ButtonStyle {
    switch self {
    case .controlReadMoreButton: return readMoreButtonStyle
    case .experimentalReadMoreButton: return greyReadMoreButtonStyle
    }
  }
}

public func projectAttributedNameAndBlurb(_ project: Project) -> NSAttributedString {
  let isProjectNamePunctuated = project.name.unicodeScalars.last
    .map(CharacterSet.punctuationCharacters.contains)
    .coalesceWith(false)

  let projectName = isProjectNamePunctuated ? project.name : "\(project.name):"

  let baseNameAttributedString = NSMutableAttributedString(
    string: "\(projectName) ",
    attributes: [
      NSAttributedString.Key.font: UIFont.ksr_title3(size: 18.0),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_soft_black
    ]
  )

  let blurbAttributedString = NSAttributedString(
    string: project.blurb,
    attributes: [
      NSAttributedString.Key.font: UIFont.ksr_title3(size: 18.0),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_400
    ]
  )

  baseNameAttributedString.append(blurbAttributedString)

  return baseNameAttributedString
}

public func projectCellBackgroundColor() -> UIColor {
  return .white
}
