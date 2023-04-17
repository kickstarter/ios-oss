import Foundation
import KsApi
import Prelude

public protocol OptimizelyClientType: AnyObject {
  func isFeatureEnabled(featureKey: String, userId: String, attributes: [String: Any?]?) -> Bool
  func track(eventKey: String, userId: String, attributes: [String: Any?]?, eventTags: [String: Any]?) throws
}

extension OptimizelyClientType {
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
