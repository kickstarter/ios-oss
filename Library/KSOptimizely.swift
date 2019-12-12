import Foundation
import KsApi
import Optimizely

public final class KSOptimizely {
  public init() {}

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
    let logLevel = OptimizelyLogLevel.debug
    let optimizely = OptimizelyClient(sdkKey: KSOptimizely.sdkKey,
    defaultLogLevel: logLevel)

    optimizely.start { result in
      switch result {
      case .failure(let error):
        print("Optimizely SDK initiliazation failed: \(error)")
      case .success:
        print("Optimizely SDK initialized successfully!")
      }

      AppEnvironment.updateOptimizelyClient(optimizely)
    }
  }

  public class func variant(for experiment: OptimizelyExperiment.Key) -> String {
    do {
      guard let user = AppEnvironment.current.currentUser,
        let optimizelyClient = AppEnvironment.current.optimizelyClient else {
        return OptimizelyExperiment.Variant.control.rawValue
      }
      let userId = String(user.id)
      let variationKey = try optimizelyClient.activate(experimentKey: experiment.rawValue,
                                                       userId: userId, attributes: nil)
      return variationKey
    } catch {
      print("Optimizely SDK activation failed: \(error)")
    }
    return ""
  }
}
