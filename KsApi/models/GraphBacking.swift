import Foundation

public struct GraphBacking: Swift.Decodable, Equatable {
  public var errorReason: String?
  public var project: Project?
  public var status: Status

  public struct Project: Swift.Decodable, Equatable {
    public var finalCollectionDate: String?
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

extension GraphBacking.Project {
  private enum CodingKeys: String, CodingKey {
    case finalCollectionDate, id, name, slug
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decode(String.self, forKey: .id)
    self.name = try values.decode(String.self, forKey: .name)
    self.slug = try values.decode(String.self, forKey: .slug)
    self.finalCollectionDate = try? values.decode(String.self,
                                                 forKey: .finalCollectionDate)
  }
}
