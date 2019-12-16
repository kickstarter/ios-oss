import Foundation
import Optimizely

public protocol OptimizelyClientType: class {
  func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
}

extension OptimizelyClient: OptimizelyClientType {}
 
