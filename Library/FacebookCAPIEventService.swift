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
  public static func triggerCapiEvent(
    for eventName: FacebookCAPIEventName,
    projectId: String,
    userEmail: String
  ) {
    guard let externalId = AppTrackingTransparencyService.advertisingIdentifier() else { return }

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

  // MARK: Private Methods

  private static func createMutationInput(
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
