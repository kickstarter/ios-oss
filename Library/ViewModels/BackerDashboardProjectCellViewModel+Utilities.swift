import Foundation
import UIKit

func metadataString(for project: any BackerDashboardProjectCellViewModel.ProjectCellModel) -> String {
  guard !isProjectPrelaunch(project) else { return Strings.Coming_soon() }

  switch project.state {
  case .live:
    guard let deadline = project.deadline else {
      return ""
    }

    let duration = Format.duration(secondsInUTC: deadline, abbreviate: true, useToGo: false)
    return "\(duration.time) \(duration.unit)"
  default:
    return stateString(for: project)
  }
}

func percentFundedString(
  for project: any BackerDashboardProjectCellViewModel
    .ProjectCellModel
) -> NSAttributedString {
  let percentage = Format.percentage(project.percentFunded)

  switch project.state {
  case .live, .successful:
    return NSAttributedString(string: percentage, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 10),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_create_700
    ])
  default:
    return NSAttributedString(string: percentage, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 10),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400
    ])
  }
}

func progressBarColorForProject(
  _ project: any BackerDashboardProjectCellViewModel
    .ProjectCellModel
) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_300
  }
}

func metadataBackgroundColorForProject(
  _ project: any BackerDashboardProjectCellViewModel
    .ProjectCellModel
) -> UIColor {
  guard !isProjectPrelaunch(project) else {
    return .ksr_create_700
  }

  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_700
  }
}

func titleString(
  for project: any BackerDashboardProjectCellViewModel
    .ProjectCellModel
) -> NSAttributedString {
  switch project.state {
  case .live, .successful:
    return NSAttributedString(string: project.name, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 13),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
    ])
  default:
    return NSAttributedString(string: project.name, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 13),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400
    ])
  }
}

private func stateString(for project: any BackerDashboardProjectCellViewModel.ProjectCellModel) -> String {
  switch project.state {
  case .canceled:
    return Strings.profile_projects_status_canceled()
  case .successful:
    return Strings.profile_projects_status_successful()
  case .suspended:
    return Strings.profile_projects_status_suspended()
  case .failed:
    return Strings.profile_projects_status_unsuccessful()
  default:
    return ""
  }
}

func isProjectPrelaunch(_ project: any BackerDashboardProjectCellViewModel.ProjectCellModel) -> Bool {
  switch (project.displayPrelaunch, project.prelaunchActivated, project.launchedAt) {
  // GraphQL requests using ProjectFragment will populate displayPrelaunch and prelaunchActivated
  case (.some(true), .some(true), _):
    return true

  // V1 requests may not return displayPrelaunch and prelaunchActivated.
  // But if no launch date is set, we can assume this is a prelaunch project.
  case let (.none, .none, .some(timeValue)):
    return timeValue <= 0
  default:
    return false
  }
}
