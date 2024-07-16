import Foundation

public struct CreatePaymentIntentInput: GraphMutationInput, Encodable {
  let projectId: String
  let backingId: String
  let amountDollars: String
  let checkoutId: String
  let digitalMarketingAttributed: Bool?
  let paymentIntentContext: GraphAPI.StripeIntentContextTypes?

  /**
   Initializes a CreateCheckout.

   - parameter projectId: The GraphID of the Project.
   - parameter backingId: The GraphID of the backing.
   - parameter amountDollars: The amount.
   - parameter checkoutId: The GraphID returned from our CreateCheckout mutation.
   - parameter digitalMarketingAttributed: The optional ID of the ShippingRule's Location.
   - parameter paymentIntentContext: The GraphAPI.StripeIntentContextType. Used to help the backend debug
   */
  public init(
    projectId: String,
    backingId: String,
    amountDollars: String,
    checkoutId: String,
    digitalMarketingAttributed: Bool?
  ) {
    self.projectId = projectId
    self.backingId = backingId
    self.amountDollars = amountDollars
    self.checkoutId = checkoutId
    self.digitalMarketingAttributed = digitalMarketingAttributed
    self.paymentIntentContext = .postCampaignCheckout
  }
}
