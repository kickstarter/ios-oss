import Foundation

public struct FetchProjectsEnvelope: Decodable {
  public var projects: [Project]
  public var cursor: String?
  public var hasPreviousPage: Bool
  public var totalCount: Int
}
