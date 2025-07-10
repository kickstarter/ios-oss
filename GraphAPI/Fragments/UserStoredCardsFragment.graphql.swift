// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension GraphAPI {
  struct UserStoredCardsFragment: GraphAPI.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment UserStoredCardsFragment on UserCreditCardTypeConnection { __typename nodes { __typename expirationDate id lastFour type stripeCardId } totalCount }"#
    }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserCreditCardTypeConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node?]?.self),
      .field("totalCount", Int.self),
    ] }

    /// A list of nodes.
    public var nodes: [Node?]? { __data["nodes"] }
    public var totalCount: Int { __data["totalCount"] }

    /// Node
    ///
    /// Parent Type: `CreditCard`
    public struct Node: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreditCard }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("expirationDate", GraphAPI.Date.self),
        .field("id", String.self),
        .field("lastFour", String.self),
        .field("type", GraphQLEnum<GraphAPI.CreditCardTypes>.self),
        .field("stripeCardId", String.self),
      ] }

      /// When the credit card expires.
      public var expirationDate: GraphAPI.Date { __data["expirationDate"] }
      /// The card ID
      public var id: String { __data["id"] }
      /// The last four digits of the credit card number.
      public var lastFour: String { __data["lastFour"] }
      /// The card type.
      public var type: GraphQLEnum<GraphAPI.CreditCardTypes> { __data["type"] }
      /// Stripe card id
      public var stripeCardId: String { __data["stripeCardId"] }
    }
  }

}