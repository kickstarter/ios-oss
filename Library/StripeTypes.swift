import Foundation
import KsApi

public protocol StripeSCARequiring {
  var checkoutId: String? { get }
  var clientSecret: String? { get }
  var requiresSCAFlow: Bool { get }
}

extension UpdateBackingEnvelope: StripeSCARequiring {
  public var checkoutId: String? {
    return self.updateBacking.checkout.id
  }

  public var requiresSCAFlow: Bool {
    return self.updateBacking.checkout.backing.requiresAction
  }

  public var clientSecret: String? {
    return self.updateBacking.checkout.backing.clientSecret
  }
}

extension CreateBackingEnvelope: StripeSCARequiring {
  public var checkoutId: String? {
    return self.createBacking.checkout.id
  }

  public var requiresSCAFlow: Bool {
    return self.createBacking.checkout.backing.requiresAction
  }

  public var clientSecret: String? {
    return self.createBacking.checkout.backing.clientSecret
  }
}

public enum StripePaymentHandlerActionStatus {
  case canceled
  case failed
  case succeeded
}

public protocol StripePaymentHandlerActionStatusType {
  var status: StripePaymentHandlerActionStatus { get }
}
