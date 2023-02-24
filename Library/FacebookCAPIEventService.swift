import Foundation
import KsApi

public enum FacebookCAPIEventName: String {
  /// viewing a project page
  case ViewContent
  /// viewing the reward selection screen
  case InitiateCheckout
  /// viewing the checkout page where you enter credit card details
  case AddPaymentInfo
  /// completion of backing
  case Purchase
}

public struct FacebookCAPIEventService {
  public static func createMutationInput(
    for eventName: FacebookCAPIEventName,
    projectId: String,
    externalId: String,
    userEmail: String,
    currency: String? = nil,
    value: String? = nil
  ) -> TriggerCapiEventInput {
    TriggerCapiEventInput(
      projectId: projectId,
      eventName: eventName.rawValue,
      externalId: externalId,
      userEmail: userEmail,
      appData: GraphAPI.AppDataInput(extinfo: ["i2"]),
      customData: GraphAPI.CustomDataInput(currency: currency, value: value)
    )
  }
}
