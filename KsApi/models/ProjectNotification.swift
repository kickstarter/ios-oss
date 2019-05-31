import Argo
import Curry
import Foundation
import Runes

public struct ProjectNotification: Equatable {
  public let email: Bool
  public let id: Int
  public let mobile: Bool
  public let project: Project

  public struct Project: Equatable {
    public let id: Int
    public let name: String
  }
}

extension ProjectNotification: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectNotification> {
    return curry(ProjectNotification.init)
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
