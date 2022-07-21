import Foundation
import Library
import Stripe

extension STPPaymentHandlerActionStatus: StripePaymentHandlerActionStatusType {
  public var status: StripePaymentHandlerActionStatus {
    switch self {
    case .canceled: return .canceled
    case .failed: return .failed
    case .succeeded: return .succeeded
    @unknown default:
      fatalError()
    }
  }
}
