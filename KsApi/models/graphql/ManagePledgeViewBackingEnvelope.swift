import Argo
import Foundation
import ReactiveSwift

public struct ManagePledgeViewBackingEnvelope: Swift.Decodable {
  public var project: GraphProject
  public var backing: GraphBacking
}

public extension ManagePledgeViewBackingEnvelope {
  private enum CodingKeys: CodingKey {
    case backing
    case project
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.backing = try values.decode(GraphBacking.self, forKey: .backing)
    self.project = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .backing)
      .decode(GraphProject.self, forKey: .project)
  }
}
