import Foundation
import KsApi
import Prelude

public protocol OptimizelyClientType: AnyObject {
  func activate(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
  func getVariationKey(experimentKey: String, userId: String, attributes: [String: Any?]?) throws -> String
  func track(eventKey: String, userId: String, attributes: [String: Any?]?, eventTags: [String: Any]?) throws
}

extension OptimizelyClientType {
  public func variant(
    for experiment: OptimizelyExperiment.Key,
    userId: String,
    isAdmin: Bool
  ) -> OptimizelyExperiment.Variant {
    let variationString: String?
    if isAdmin {
      variationString = try? self.getVariationKey(
        experimentKey: experiment.rawValue, userId: userId, attributes: nil
      )
    } else {
      variationString = try? self.activate(
        experimentKey: experiment.rawValue, userId: userId, attributes: nil
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
}

public func optimizelyTrackingAttributesAndEventTags(
  with user: User?,
  project: Project,
  refTag: RefTag?
) -> ([String: Any], [String: Any]) {
  let properties: [String: Any] = [
    "user_backed_projects_count": user?.stats.backedProjectsCount,
    "user_launched_projects_count": user?.stats.createdProjectsCount,
    "user_country": user?.location?.country.lowercased() ?? AppEnvironment.current.config?.countryCode,
    "user_facebook_account": user?.facebookConnected,
    "user_display_language": AppEnvironment.current.language.rawValue,
    "session_os_version": AppEnvironment.current.device.systemVersion,
    "session_user_is_logged_in": user != nil,
    "session_app_release_version": AppEnvironment.current.mainBundle.shortVersionString,
    "session_apple_pay_device": AppEnvironment.current.applePayCapabilities.applePayDevice(),
    "session_device_format": AppEnvironment.current.device.deviceFormat
  ]
  .compact()

  let eventTags: [String: Any] = [
    "project_subcategory": project.category.name,
    "project_category": project.category.parent?.name,
    "project_country": project.location.country,
    "project_user_has_watched": project.personalization.isStarred,
    "ref_tag": refTag?.stringTag,
    "referrer_credit": (cookieRefTagFor(project: project) ?? refTag)?.stringTag
  ]
  .compact()

  return (properties, eventTags)
}
