import Foundation
import KsApi
import Prelude

public protocol OptimizelyClientType: AnyObject {
  func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
  func getVariationKey(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
  func allExperiments() -> [String]
  func isFeatureEnabled(featureKey: String, userId: String, attributes: [String: Any?]?) -> Bool
  func track(eventKey: String, userId: String, attributes: [String: Any?]?, eventTags: [String: Any]?) throws
}

extension OptimizelyClientType {
  public func variant(
    for experiment: OptimizelyExperiment.Key,
    userAttributes: [String: Any]? = optimizelyUserAttributes()
  ) -> OptimizelyExperiment.Variant {
    let variationString: String?

    let userId = deviceIdentifier(uuid: UUID())
    let isAdmin = AppEnvironment.current.currentUser?.isAdmin ?? false

    if isAdmin {
      variationString = try? self.getVariationKey(
        experimentKey: experiment.rawValue, userId: userId, attributes: userAttributes
      )
    } else {
      variationString = try? self.activate(
        experimentKey: experiment.rawValue, userId: userId, attributes: userAttributes
      )
    }

    guard
      let variation = variationString,
      let variant = OptimizelyExperiment.Variant(rawValue: variation)
    else {
      return .control
    }

    return variant
  }

  /*
   Calls `getVariation` on the Optimizely SDK for the given experiment,
   using the default attributes and deviceId

   Does *not* record an Optimizely impression. If you wish to record an experiment impression, use
   `variant(for experiment)`, which calls `activate` on the Optimizely SDK
   */

  public func getVariation(for experimentKey: String) -> OptimizelyExperiment.Variant {
    let userId = deviceIdentifier(uuid: UUID())
    let attributes = optimizelyUserAttributes()
    let variationString = try? self.getVariationKey(
      experimentKey: experimentKey, userId: userId, attributes: attributes
    )

    guard
      let variation = variationString,
      let variant = OptimizelyExperiment.Variant(rawValue: variation)
    else {
      return .control
    }

    return variant
  }

  /* Returns all experiments the app knows about */

  public func allExperiments() -> [String] {
    return OptimizelyExperiment.Key.allCases.map { $0.rawValue }
  }

  /* Returns all features the app knows about */

  public func allFeatures() -> [OptimizelyFeature] {
    return OptimizelyFeature.allCases
  }

  public func isFeatureEnabled(featureKey: String) -> Bool {
    return self.isFeatureEnabled(
      featureKey: featureKey,
      userId: deviceIdentifier(uuid: UUID()),
      attributes: optimizelyUserAttributes()
    )
  }

  public func track(eventName: String) {
    let userAttributes = optimizelyUserAttributes()
    let userId = deviceIdentifier(uuid: UUID())

    try? self.track(
      eventKey: eventName,
      userId: userId,
      attributes: userAttributes,
      eventTags: nil
    )
  }
}

// MARK: - Tracking Properties

public func optimizelyProperties(environment: Environment? = AppEnvironment.current) -> [String: Any]? {
  guard let env = environment else { return nil }

  let environmentType = env.environmentType

  var sdkKey: String

  switch environmentType {
  case .production:
    sdkKey = Secrets.OptimizelySDKKey.production
  case .staging:
    sdkKey = Secrets.OptimizelySDKKey.staging
  case .development, .local, .custom:
    sdkKey = Secrets.OptimizelySDKKey.development
  }

  return [
    "optimizely_api_key": sdkKey,
    "optimizely_environment": environmentType.description
  ]
}

public func optimizelyUserAttributes(
  with project: Project? = nil,
  refTag: RefTag? = nil
) -> [String: Any] {
  let user = AppEnvironment.current.currentUser
  let user_country = user?.location?.country
  let properties: [String: Any?] = [
    "user_distinct_id": debugDeviceIdentifier(),
    "user_backed_projects_count": user?.stats.backedProjectsCount,
    "user_launched_projects_count": user?.stats.createdProjectsCount,
    "user_country": (user_country ?? AppEnvironment.current.config?.countryCode)?.lowercased(),
    "user_facebook_account": user?.facebookConnected,
    "user_display_language": AppEnvironment.current.language.rawValue,
    "session_os_version": AppEnvironment.current.device.systemVersion,
    "session_user_is_logged_in": user != nil,
    "session_app_release_version": AppEnvironment.current.mainBundle.shortVersionString,
    "session_apple_pay_device": AppEnvironment.current.applePayCapabilities.applePayDevice(),
    "session_device_type": AppEnvironment.current.device.deviceType
  ]

  return properties.compact()
    .withAllValuesFrom(sessionRefTagProperties(with: project, refTag: refTag))
}

private func sessionRefTagProperties(with project: Project?, refTag: RefTag?) -> [String: Any] {
  return ([
    "session_referrer_credit": project.flatMap(cookieRefTagFor(project:)).coalesceWith(refTag)?.stringTag,
    "session_ref_tag": refTag?.stringTag
  ] as [String: Any?]).compact()
}

private func debugDeviceIdentifier() -> String? {
  guard
    AppEnvironment.current.environmentType != .production,
    AppEnvironment.current.mainBundle.isRelease == false
  else { return nil }

  return deviceIdentifier(uuid: UUID())
}
