import Foundation

extension Project.Dates {
  internal static let template = Project.Dates(
    deadline: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 15.0,
    featuredAt: nil,
    launchedAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 15.0,
    stateChangedAt: Date(
      timeIntervalSince1970: 1_475_361_315
    ).timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 15.0
  )
}
