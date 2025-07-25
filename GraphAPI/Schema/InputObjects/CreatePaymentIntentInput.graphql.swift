// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Autogenerated input type of CreatePaymentIntent
public struct CreatePaymentIntentInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    projectId: ID,
    amount: String,
    paymentIntentContext: GraphQLNullable<GraphQLEnum<StripeIntentContextTypes>> = nil,
    digitalMarketingAttributed: GraphQLNullable<Bool> = nil,
    backingId: GraphQLNullable<ID> = nil,
    checkoutId: GraphQLNullable<ID> = nil,
    clientMutationId: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "projectId": projectId,
      "amount": amount,
      "paymentIntentContext": paymentIntentContext,
      "digitalMarketingAttributed": digitalMarketingAttributed,
      "backingId": backingId,
      "checkoutId": checkoutId,
      "clientMutationId": clientMutationId
    ])
  }

  /// kickstarter project id
  public var projectId: ID {
    get { __data["projectId"] }
    set { __data["projectId"] = newValue }
  }

  /// total amount to be paid (eg. 10.55)
  public var amount: String {
    get { __data["amount"] }
    set { __data["amount"] = newValue }
  }

  /// Context in which this stripe intent is created
  public var paymentIntentContext: GraphQLNullable<GraphQLEnum<StripeIntentContextTypes>> {
    get { __data["paymentIntentContext"] }
    set { __data["paymentIntentContext"] = newValue }
  }

  /// if the payment is attributed to digital marketing (default: false)
  public var digitalMarketingAttributed: GraphQLNullable<Bool> {
    get { __data["digitalMarketingAttributed"] }
    set { __data["digitalMarketingAttributed"] = newValue }
  }

  /// Current backing id for tracking purposes
  public var backingId: GraphQLNullable<ID> {
    get { __data["backingId"] }
    set { __data["backingId"] = newValue }
  }

  /// Current checkout id for tracking purposes
  public var checkoutId: GraphQLNullable<ID> {
    get { __data["checkoutId"] }
    set { __data["checkoutId"] = newValue }
  }

  /// A unique identifier for the client performing the mutation.
  public var clientMutationId: GraphQLNullable<String> {
    get { __data["clientMutationId"] }
    set { __data["clientMutationId"] = newValue }
  }
}
