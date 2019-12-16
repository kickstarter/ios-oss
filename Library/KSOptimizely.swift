import Foundation
import KsApi

public final class KSOptimizely {
  public init() {}

//  public func variant(for experiment: OptimizelyExperiment.Key) -> String {
//    do {
//      guard let user = AppEnvironment.current.currentUser,
//        let optimizelyClient = AppEnvironment.current.optimizelyClient else {
//          return OptimizelyExperiment.Variant.control.rawValue
//      }
//      let userId = String(user.id)
//      let variationKey = try optimizelyClient.activate(
//        experimentKey: experiment.rawValue,
//        userId: userId, attributes: nil
//      )
//      return variationKey
//    } catch {
//      print("Optimizely SDK activation failed: \(error)")
//    }
//    return ""
//  }
}
