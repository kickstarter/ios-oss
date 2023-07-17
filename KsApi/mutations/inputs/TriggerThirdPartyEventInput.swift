import Foundation

public struct TriggerThirdPartyEventInput: GraphMutationInput {
  let deviceId: String
  let eventName: String
  let projectId: String
  let pledgeAmount: Double?
  let shipping: Double?
  let transactionId: String?
  let userId: String?
  let appData: GraphAPI.AppDataInput?
  let clientMutationId: String

  public init(
    deviceId: String,
    eventName: String,
    projectId: String,
    pledgeAmount: Double?,
    shipping: Double?,
    transactionId: String?,
    userId: String?,
    appData: GraphAPI.AppDataInput?,
    clientMutationId: String
  ) {
    self.deviceId = deviceId
    self.eventName = eventName
    self.projectId = projectId
    self.pledgeAmount = pledgeAmount
    self.shipping = shipping
    self.transactionId = transactionId
    self.userId = userId
    self.appData = appData
    self.clientMutationId = clientMutationId
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "deviceId": self.deviceId,
      "eventName": self.eventName,
      "projectId": self.projectId,
      "pledgeAmount": self.pledgeAmount,
      "shipping": self.shipping,
      "transactionId": self.transactionId,
      "userId": self.userId,
      "appData": self.appData,
      "clientMutationId": self.clientMutationId
    ]
  }
}
