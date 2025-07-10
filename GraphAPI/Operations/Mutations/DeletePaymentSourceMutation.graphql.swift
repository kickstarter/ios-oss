// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  class DeletePaymentSourceMutation: GraphQLMutation {
    public static let operationName: String = "DeletePaymentSource"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeletePaymentSource($input: PaymentSourceDeleteInput!) { paymentSourceDelete(input: $input) { __typename user { __typename storedCards { __typename ...UserStoredCardsFragment } } } }"#,
        fragments: [UserStoredCardsFragment.self]
      ))

    public var input: PaymentSourceDeleteInput

    public init(input: PaymentSourceDeleteInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    public struct Data: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentSourceDelete", PaymentSourceDelete?.self, arguments: ["input": .variable("input")]),
      ] }

      /// Delete a user's payment source
      public var paymentSourceDelete: PaymentSourceDelete? { __data["paymentSourceDelete"] }

      /// PaymentSourceDelete
      ///
      /// Parent Type: `PaymentSourceDeletePayload`
      public struct PaymentSourceDelete: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PaymentSourceDeletePayload }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("user", User?.self),
        ] }

        public var user: User? { __data["user"] }

        /// PaymentSourceDelete.User
        ///
        /// Parent Type: `User`
        public struct User: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("storedCards", StoredCards?.self),
          ] }

          /// Stored Cards
          public var storedCards: StoredCards? { __data["storedCards"] }

          /// PaymentSourceDelete.User.StoredCards
          ///
          /// Parent Type: `UserCreditCardTypeConnection`
          public struct StoredCards: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreditCardTypeConnection }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(UserStoredCardsFragment.self),
            ] }

            /// A list of nodes.
            public var nodes: [Node?]? { __data["nodes"] }
            public var totalCount: Int { __data["totalCount"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var userStoredCardsFragment: UserStoredCardsFragment { _toFragment() }
            }

            public typealias Node = UserStoredCardsFragment.Node
          }
        }
      }
    }
  }

}