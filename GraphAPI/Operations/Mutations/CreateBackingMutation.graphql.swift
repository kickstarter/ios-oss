// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateBackingMutation: GraphQLMutation {
  public static let operationName: String = "CreateBacking"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateBacking($input: CreateBackingInput!) { createBacking(input: $input) { __typename checkout { __typename ...CheckoutFragment } } }"#,
      fragments: [CheckoutFragment.self]
    ))

  public var input: CreateBackingInput

  public init(input: CreateBackingInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createBacking", CreateBacking?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Create a backing and checkout and process payment.
    public var createBacking: CreateBacking? { __data["createBacking"] }

    public init(
      createBacking: CreateBacking? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "createBacking": createBacking._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CreateBackingMutation.Data.self)
        ]
      ))
    }

    /// CreateBacking
    ///
    /// Parent Type: `CreateBackingPayload`
    public struct CreateBacking: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreateBackingPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("checkout", Checkout?.self),
      ] }

      public var checkout: Checkout? { __data["checkout"] }

      public init(
        checkout: Checkout? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.CreateBackingPayload.typename,
            "checkout": checkout._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CreateBackingMutation.Data.CreateBacking.self)
          ]
        ))
      }

      /// CreateBacking.Checkout
      ///
      /// Parent Type: `Checkout`
      public struct Checkout: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Checkout }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(CheckoutFragment.self),
        ] }

        /// The backing that the checkout is modifying.
        public var backing: Backing { __data["backing"] }
        public var id: GraphAPI.ID { __data["id"] }
        /// The current state of the checkout
        public var state: GraphQLEnum<GraphAPI.CheckoutState> { __data["state"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var checkoutFragment: CheckoutFragment { _toFragment() }
        }

        public init(
          backing: Backing,
          id: GraphAPI.ID,
          state: GraphQLEnum<GraphAPI.CheckoutState>
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Checkout.typename,
              "backing": backing._fieldData,
              "id": id,
              "state": state,
            ],
            fulfilledFragments: [
              ObjectIdentifier(CreateBackingMutation.Data.CreateBacking.Checkout.self),
              ObjectIdentifier(CheckoutFragment.self)
            ]
          ))
        }

        public typealias Backing = CheckoutFragment.Backing
      }
    }
  }
}
