import Foundation
import KsApi

public enum FacebookCAPIEventName: String {
  /// viewing a project page
  case ProjectPageViewed = "ViewContent"
  /// viewing the reward selection screen
  case RewardSelectionViewed = "InitiateCheckout"
  /// viewing the checkout page where you enter credit card details
  case AddNewPaymentMethod = "AddPaymentInfo"
  /// completion of backing
  case BackingComplete = "Purchase"
}

public struct FacebookCAPI {
  public static func triggerEvent(
    for eventName: FacebookCAPIEventName,
    projectId: String,
    userEmail: String
  ) {
    guard let externalId = AppTrackingTransparency.advertisingIdentifier() else { return }

    let eventInput = self.createMutationInput(
      for: eventName,
      projectId: projectId,
      externalId: externalId,
      userEmail: userEmail
    )

    _ = AppEnvironment
      .current
      .apiService
      .triggerCapiEventInput(input: eventInput)
  }

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
