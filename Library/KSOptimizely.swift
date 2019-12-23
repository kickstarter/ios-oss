import Foundation
import KsApi
import Optimizely

public final class KSOptimizely {
  public init() {}

  public static var sdkKey: String {
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

  public class func setup(with key: String) {
    let logLevel = OptimizelyLogLevel.debug
    let optimizely = OptimizelyClient(
      sdkKey: key,
      defaultLogLevel: logLevel
    )

    optimizely.start { result in
      switch result {
      case let .failure(error):
        print("Optimizely SDK initiliazation failed: \(error)")
      case .success:
        print("Optimizely SDK initialized successfully!")
      }

      AppEnvironment.updateOptimizelyClient(optimizely)
    }
  }
}

public func variant(for experiment: OptimizelyExperiment.Key) -> String {
  do {
    guard let user = AppEnvironment.current.currentUser,
      let optimizelyClient = AppEnvironment.current.optimizelyClient else {
      return OptimizelyExperiment.Variant.control.rawValue
    }
    let userId = String(user.id)
    let variationKey = try optimizelyClient.activate(
      experimentKey: experiment.rawValue,
      userId: userId, attributes: nil
    )
    return variationKey
  } catch {
    print("Optimizely SDK activation failed: \(error)")
  }
  return ""
}
