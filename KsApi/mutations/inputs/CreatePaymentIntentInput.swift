import Foundation

public struct CreatePaymentIntentInput: GraphMutationInput, Encodable {
  let projectId: String
  let amountDollars: String
  let digitalMarketingAttributed: Bool?

  /**
   Initializes a CreateCheckout.

   - parameter projectId: The GraphID of the Project.
   - parameter amountDollars: The amount.
   - parameter digitalMarketingAttributed: The optional ID of the ShippingRule's Location.
   */
  public init(
    projectId: String,
    amountDollars: String,
    digitalMarketingAttributed: Bool?
  ) {
    self.projectId = projectId
    self.amountDollars = amountDollars
    self.digitalMarketingAttributed = digitalMarketingAttributed
  }
}
