import Foundation

public struct CreatePaymentIntentInput: GraphMutationInput, Encodable {
  let projectId: String
  let amountDollars: String
  let digitalMarketingAttributed: Bool?
  let paymentIntentContext: GraphAPI.StripeIntentContextTypes?

  /**
   Initializes a CreateCheckout.

   - parameter projectId: The GraphID of the Project.
   - parameter amountDollars: The amount.
   - parameter digitalMarketingAttributed: The optional ID of the ShippingRule's Location.
   - parameter paymentIntentContext: The optional GraphAPI.StripeIntentContextType. Used to help the backend debug
   */
  public init(
    projectId: String,
    amountDollars: String,
    digitalMarketingAttributed: Bool?,
    paymentIntentContext: GraphAPI.StripeIntentContextTypes?
  ) {
    self.projectId = projectId
    self.amountDollars = amountDollars
    self.digitalMarketingAttributed = digitalMarketingAttributed
    self.paymentIntentContext = paymentIntentContext
  }
}
