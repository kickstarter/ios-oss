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
    "backings_count": user?.stats.backedProjectsCount,
    "location": user?.location?.country.lowercased(),
    "os_version": AppEnvironment.current.device.systemVersion,
    "logged_in": user != nil,
    "chosen_currency": project.stats.currentCurrency,
    "locale": AppEnvironment.current.locale.identifier
  ]
  .compact()

  let eventTags: [String: Any] = [
    "project_subcategory": project.category.name,
    "ref_tag": refTag?.stringTag,
    "referrer_credit": (cookieRefTagFor(project: project) ?? refTag)?.stringTag
  ]
  .compact()

  return (properties, eventTags)
}
