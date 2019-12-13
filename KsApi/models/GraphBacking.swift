import Foundation

public struct GraphBacking: Swift.Decodable, Equatable {
  public var errorReason: String?
  public var project: Project?
  public var status: Status

  public struct Project: Swift.Decodable, Equatable {
    public var id: String
    public var name: String
    public var slug: String
  }

  public enum Status: String, CaseIterable, Swift.Decodable {
    case authenticationRequired = "authentication_required"
    case canceled
    case collected
    case dropped
    case errored
    case pledged
    case preauth
  }
}
