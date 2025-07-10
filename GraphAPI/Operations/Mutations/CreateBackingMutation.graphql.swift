// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class CreateBackingMutation: GraphQLMutation {
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

          public typealias Backing = CheckoutFragment.Backing
        }
      }
    }
  }

}