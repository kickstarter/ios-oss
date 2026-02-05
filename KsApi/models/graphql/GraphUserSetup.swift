import Foundation

public struct GraphUserSetup: Decodable, Equatable {
  public var email: String? = nil
  public var enabledFeatures: Set<ServerFeature>
  public var ppoHasAction: Bool? = nil
  public var backingActionCount: Int? = nil
}
