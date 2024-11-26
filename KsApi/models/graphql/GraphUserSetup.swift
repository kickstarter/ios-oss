import Foundation

public struct GraphUserSetup: Decodable, Equatable {
  public var email: String?
  public var enabledFeatures: [ServerFeature]
}
