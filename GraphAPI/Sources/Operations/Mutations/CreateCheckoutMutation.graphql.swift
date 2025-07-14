// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateCheckoutMutation: GraphQLMutation {
  public static let operationName: String = "CreateCheckout"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateCheckout($input: CreateCheckoutInput!) { createCheckout(input: $input) { __typename clientMutationId checkout { __typename id paymentUrl backing { __typename id } } } }"#
    ))

  public var input: CreateCheckoutInput

  public init(input: CreateCheckoutInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createCheckout", CreateCheckout?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Create a backing and checkout without syncing to Rosie
    public var createCheckout: CreateCheckout? { __data["createCheckout"] }

    public init(
      createCheckout: CreateCheckout? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "createCheckout": createCheckout._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CreateCheckoutMutation.Data.self)
        ]
      ))
    }

    /// CreateCheckout
    ///
    /// Parent Type: `CreateCheckoutPayload`
    public struct CreateCheckout: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreateCheckoutPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientMutationId", String?.self),
        .field("checkout", Checkout?.self),
      ] }

      /// A unique identifier for the client performing the mutation.
      public var clientMutationId: String? { __data["clientMutationId"] }
      public var checkout: Checkout? { __data["checkout"] }

      public init(
        clientMutationId: String? = nil,
        checkout: Checkout? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.CreateCheckoutPayload.typename,
            "clientMutationId": clientMutationId,
            "checkout": checkout._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CreateCheckoutMutation.Data.CreateCheckout.self)
          ]
        ))
      }

      /// CreateCheckout.Checkout
      ///
      /// Parent Type: `Checkout`
      public struct Checkout: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Checkout }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("paymentUrl", String?.self),
          .field("backing", Backing.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        public var paymentUrl: String? { __data["paymentUrl"] }
        /// The backing that the checkout is modifying.
        public var backing: Backing { __data["backing"] }

        public init(
          id: GraphAPI.ID,
          paymentUrl: String? = nil,
          backing: Backing
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Checkout.typename,
              "id": id,
              "paymentUrl": paymentUrl,
              "backing": backing._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(CreateCheckoutMutation.Data.CreateCheckout.Checkout.self)
            ]
          ))
        }

        /// CreateCheckout.Checkout.Backing
        ///
        /// Parent Type: `Backing`
        public struct Backing: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GraphAPI.ID.self),
          ] }

          public var id: GraphAPI.ID { __data["id"] }

          public init(
            id: GraphAPI.ID
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Backing.typename,
                "id": id,
              ],
              fulfilledFragments: [
                ObjectIdentifier(CreateCheckoutMutation.Data.CreateCheckout.Checkout.Backing.self)
              ]
            ))
          }
        }
      }
    }
  }
}
