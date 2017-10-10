import KsApi
import Prelude

public struct ProjectActivityData {
  public fileprivate(set) var activities: [Activity]
  public fileprivate(set) var project: Project
  public fileprivate(set) var groupedDates: Bool

    public enum lens {
    public static let activities = Lens<ProjectActivityData, [Activity]>(
      view: { $0.activities },
      set: { ProjectActivityData(activities: $0, project: $1.project, groupedDates: $1.groupedDates) }
    )

    public static let project = Lens<ProjectActivityData, Project>(
      view: { $0.project },
      set: { ProjectActivityData(activities: $1.activities, project: $0, groupedDates: $1.groupedDates) }
    )

    public static let groupedDates = Lens<ProjectActivityData, Bool>(
      view: { $0.groupedDates },
      set: { ProjectActivityData(activities: $1.activities, project: $1.project, groupedDates: $0) }
    )
  }
}
