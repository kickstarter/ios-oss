import KsApi
import Prelude
import Prelude_UIKit
import UIKit

public enum ProjectCampaignExperimentType {
  case control
  case experimental

  public var buttonStyle: ProjectCampaignButtonStyleType {
    switch self {
    case .control:
      return .controlReadMoreButton
    case .experimental:
      return .experimentalReadMoreButton
    }
  }

  public var viewHidden: Bool {
    switch self {
    case .control:
      return false
    case .experimental:
      return true
    }
  }

  public var stackViewSpacing: CGFloat {
    switch self {
    case .control:
      return Styles.grid(0)
    case .experimental:
      return Styles.grid(4)
    }
  }
}

public enum ProjectCampaignButtonStyleType: Equatable {
  case controlReadMoreButton
  case experimentalReadMoreButton

  public var style: ButtonStyle {
    switch self {
    case .controlReadMoreButton: return controlReadMoreButtonStyle
    case .experimentalReadMoreButton: return experimentalReadMoreButtonStyle
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
