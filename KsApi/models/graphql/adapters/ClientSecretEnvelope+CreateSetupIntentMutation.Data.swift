import Foundation
import ReactiveSwift

extension ClientSecretEnvelope {
  /**
   Returns a minimal `ClientSecretEnvelope` from a `CreateSetupIntentMutation.Data`
   */
  static func clientSecretEnvelope(from data: GraphAPI.CreateSetupIntentMutation
    .Data) -> ClientSecretEnvelope? {
    guard let clientSecret = data.createSetupIntent?.clientSecret
    else { return nil }

    return ClientSecretEnvelope(clientSecret: clientSecret)
  }
}
