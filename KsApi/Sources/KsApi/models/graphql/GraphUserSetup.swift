import Foundation

public struct GraphUserSetup: Decodable, Equatable {
  public var email: String?
  public var enabledFeatures: Set<ServerFeature>
  public var ppoHasAction: Bool?
  public var backingActionCount: Int?
}
