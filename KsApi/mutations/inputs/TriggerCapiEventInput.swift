import Foundation

public struct TriggerCapiEventInput: GraphMutationInput {
  let projectId: String
  let eventName: String
  let externalId: String
  let userEmail: String?
  let appData: GraphAPI.AppDataInput?
  let customData: GraphAPI.CustomDataInput?

  public init(
    projectId: String,
    eventName: String,
    externalId: String,
    userEmail: String?,
    appData: GraphAPI.AppDataInput?,
    customData: GraphAPI.CustomDataInput?
  ) {
    self.projectId = projectId
    self.eventName = eventName
    self.externalId = externalId
    self.userEmail = userEmail
    self.appData = appData
    self.customData = customData
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "projectId": self.projectId,
      "eventName": self.eventName,
      "externalId": self.externalId,
      "userEmail": self.userEmail,
      "appData": self.appData,
      "customData": self.customData
    ]
  }
}
