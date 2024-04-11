import Foundation

public enum ProfileProjectsType: Decodable {
  case backed
  case saved

  var trackingString: String {
    switch self {
    case .backed: return "backed"
    case .saved: return "saved"
    }
  }
}

public struct FetchProjectsEnvelope: Decodable {
  public var type: ProfileProjectsType
  public var projects: [Project]
  public var cursor: String?
  public var hasNextPage: Bool
  public var totalCount: Int
}
