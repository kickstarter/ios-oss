import Prelude

extension ProjectNotification.Project {
  public enum lens {
    public static let id = Lens<ProjectNotification.Project, Int> (
      view: { $0.id },
      set: { ProjectNotification.Project(id: $0, name: $1.name) }
    )

    public static let name = Lens<ProjectNotification.Project, String> (
      view: { $0.name },
      set: { ProjectNotification.Project(id: $1.id, name: $0) }
    )
  }
}
