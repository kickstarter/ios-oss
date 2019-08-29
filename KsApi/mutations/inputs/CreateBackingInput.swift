import Foundation

public struct CreateBackingInput: GraphMutationInput {
  let projectId: Int
  let amount: String
  let locationId: String
  let rewardId: Int
  let paymentSourceId: String
  let paymentType: String

  public init(projectId: Int,
              amount: String,
              locationId: String,
              rewardId: Int,
              paymentSourceId: String,
              paymentType: String
    ) {
    self.projectId = projectId
    self.amount = amount
    self.locationId = locationId
    self.rewardId = rewardId
    self.paymentSourceId = paymentSourceId
    self.paymentType = paymentType
  }

  public func toInputDictionary() -> [String : Any] {
    return [
      "projectId": projectId,
      "amount": amount,
      "locationId": locationId,
      "rewardId": rewardId,
      "paymentSourceId": paymentSourceId,
      "paymentType": paymentType
    ]
  }
}

public struct CreateBackingEnvelope: Decodable {
  public var createBacking: CreateBacking

  public struct CreateBacking: Decodable {
    public var checkout: Checkout

    public struct Checkout: Decodable {
      public var checkoutState: CheckoutState

      public enum CheckoutState: String, Decodable, CaseIterable {
        case authorizing = "AUTHORIZING"
        case verifying = "VERIFYING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
      }
    }
  }
}
