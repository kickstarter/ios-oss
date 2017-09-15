import Argo
import Curry
import Runes
import Foundation

public struct ProjectNotification {
  public private(set) var email: Bool
  public private(set) var id: Int
  public private(set) var mobile: Bool
  public private(set) var project: Project

  public struct Project {
    public private(set) var id: Int
    public private(set) var name: String
  }
}

extension ProjectNotification: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectNotification> {
    let create = curry(ProjectNotification.init)
    return create
      <^> json <| "email"
      <*> json <| "id"
      <*> json <| "mobile"
      <*> json <| "project"
  }
}

extension ProjectNotification.Project: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectNotification.Project> {
    return curry(ProjectNotification.Project.init)
      <^> json <| "id"
      <*> json <| "name"
  }
}

extension ProjectNotification: Equatable {}
public func == (lhs: ProjectNotification, rhs: ProjectNotification) -> Bool {
  return lhs.id == rhs.id
}

extension ProjectNotification.Project: Equatable {}
public func == (lhs: ProjectNotification.Project, rhs: ProjectNotification.Project) -> Bool {
  return lhs.id == rhs.id
}
