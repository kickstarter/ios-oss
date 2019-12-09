import Foundation
import KsApi
import Optimizely

public protocol KSOptimizelyClientType: class {
  static func variant(for experiment: OptimizelyExperiment.Name) -> String
}

//extension KSOptimizelyClientType {
//  func activate(experimentKey: String, userId: String) throws -> String {
//    return ""
//  }
//}

public final class KSOptimizely: KSOptimizelyClientType {
  static let optimizelyClient: OptimizelyClient = OptimizelyClient(sdkKey: KSOptimizely.sdkKey,
                                                                   defaultLogLevel: OptimizelyLogLevel.debug)

  public init() {
  }

  private static var sdkKey: String {
    switch AppEnvironment.current.environmentType {
    case .production:
      return Secrets.OptimizelySDKKey.production
    case .development:
      return Secrets.OptimizelySDKKey.development
    case .staging:
      return Secrets.OptimizelySDKKey.staging
    default:
      return Secrets.OptimizelySDKKey.development
    }
  }

  public class func setup() {
 //   let logLevel = OptimizelyLogLevel.debug
 //   let optimizely = OptimizelyClient(sdkKey: KSOptimizely.sdkKey,
 //   defaultLogLevel: logLevel)

    optimizelyClient.start { result in
      switch result {
      case .failure(let error):
        print("Optimizely SDK initiliazation failed: \(error)")
      case .success:
        print("Optimizely SDK initialized successfully!")
      }

      //AppEnvironment.updateOptimizelyClient(KSOptimizely.self as! KSOptimizelyClientType)
    }
  }

  public class func variant(for experiment: OptimizelyExperiment.Name) -> String {
    do {
      guard let user = AppEnvironment.current.currentUser else {
        return OptimizelyExperiment.Variant.control.rawValue
      }
      let userId = String(user.id)
      let variationKey = try self.optimizelyClient.activate(experimentKey: experiment.rawValue,
                                                            userId: userId)
      return variationKey
    } catch {
      print("Optimizely SDK activation failed: \(error)")
    }
    return ""
  }
}


