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

public func backgroundColor(forCategoryId id: Int?) -> UIColor {
  switch CategoryGroup(categoryId: id) {
  case .none:
    return .ksr_grey_200
  case .culture:
    return UIColor.ksr_red_100.colorWithAlphaComponent(0.65)
  case .entertainment:
    return UIColor.ksr_violet_200.colorWithAlphaComponent(0.65)
  case .story:
    return UIColor.ksr_beige_400.colorWithAlphaComponent(0.65)
  }
}

public func strokeColor(forCategoryId id: Int?) -> UIColor {
  switch CategoryGroup(categoryId: id) {
  case .none:
    return .ksr_grey_200
  case .culture:
    return UIColor.ksr_red_400.colorWithAlphaComponent(0.15)
  case .entertainment:
    return UIColor.ksr_violet_600.colorWithAlphaComponent(0.15)
  case .story:
    return UIColor.ksr_forest_700.colorWithAlphaComponent(0.15)
  }
}
