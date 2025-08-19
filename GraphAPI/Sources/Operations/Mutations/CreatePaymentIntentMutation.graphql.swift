// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreatePaymentIntentMutation: GraphQLMutation {
  public static let operationName: String = "createPaymentIntent"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation createPaymentIntent($input: CreatePaymentIntentInput!) { createPaymentIntent(input: $input) { __typename clientSecret clientMutationId } }"#
    ))

  public var input: CreatePaymentIntentInput

  public init(input: CreatePaymentIntentInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createPaymentIntent", CreatePaymentIntent?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Create a Stripe PaymentIntent in order to collect an on-session payment via the Stripe PaymentElement
    public var createPaymentIntent: CreatePaymentIntent? { __data["createPaymentIntent"] }

    public init(
      createPaymentIntent: CreatePaymentIntent? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "createPaymentIntent": createPaymentIntent._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CreatePaymentIntentMutation.Data.self)
        ]
      ))
    }

    /// CreatePaymentIntent
    ///
    /// Parent Type: `CreatePaymentIntentPayload`
    public struct CreatePaymentIntent: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreatePaymentIntentPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientSecret", String.self),
        .field("clientMutationId", String?.self),
      ] }

      /// the stripe payment intent client secret used to complete a payment
      public var clientSecret: String { __data["clientSecret"] }
      /// A unique identifier for the client performing the mutation.
      public var clientMutationId: String? { __data["clientMutationId"] }

      public init(
        clientSecret: String,
        clientMutationId: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.CreatePaymentIntentPayload.typename,
            "clientSecret": clientSecret,
            "clientMutationId": clientMutationId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CreatePaymentIntentMutation.Data.CreatePaymentIntent.self)
          ]
        ))
      }
    }
  }
}
