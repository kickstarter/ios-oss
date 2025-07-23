// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchUserStoredCardsQuery: GraphQLQuery {
  public static let operationName: String = "FetchUserStoredCards"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchUserStoredCards { me { __typename id imageUrl: imageUrl(blur: false, width: 1024) name storedCards { __typename nodes { __typename expirationDate id lastFour type } totalCount } uid } }"#
    ))

  public init() {}

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("me", Me?.self),
    ] }

    /// You.
    public var me: Me? { __data["me"] }

    public init(
      me: Me? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "me": me._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FetchUserStoredCardsQuery.Data.self)
        ]
      ))
    }

    /// Me
    ///
    /// Parent Type: `User`
    public struct Me: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
        .field("imageUrl", alias: "imageUrl", String.self, arguments: [
          "blur": false,
          "width": 1024
        ]),
        .field("name", String.self),
        .field("storedCards", StoredCards?.self),
        .field("uid", String.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }
      /// The user's avatar.
      public var imageUrl: String { __data["imageUrl"] }
      /// The user's provided name.
      public var name: String { __data["name"] }
      /// Stored Cards
      public var storedCards: StoredCards? { __data["storedCards"] }
      /// A user's uid
      public var uid: String { __data["uid"] }

      public init(
        id: GraphAPI.ID,
        imageUrl: String,
        name: String,
        storedCards: StoredCards? = nil,
        uid: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.User.typename,
            "id": id,
            "imageUrl": imageUrl,
            "name": name,
            "storedCards": storedCards._fieldData,
            "uid": uid,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchUserStoredCardsQuery.Data.Me.self)
          ]
        ))
      }

      /// Me.StoredCards
      ///
      /// Parent Type: `UserCreditCardTypeConnection`
      public struct StoredCards: GraphAPI.SelectionSet {
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

        public init(
          nodes: [Node?]? = nil,
          totalCount: Int
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.UserCreditCardTypeConnection.typename,
              "nodes": nodes._fieldData,
              "totalCount": totalCount,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FetchUserStoredCardsQuery.Data.Me.StoredCards.self)
            ]
          ))
        }

        /// Me.StoredCards.Node
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
          ] }

          /// When the credit card expires.
          public var expirationDate: GraphAPI.Date { __data["expirationDate"] }
          /// The card ID
          public var id: String { __data["id"] }
          /// The last four digits of the credit card number.
          public var lastFour: String { __data["lastFour"] }
          /// The card type.
          public var type: GraphQLEnum<GraphAPI.CreditCardTypes> { __data["type"] }

          public init(
            expirationDate: GraphAPI.Date,
            id: String,
            lastFour: String,
            type: GraphQLEnum<GraphAPI.CreditCardTypes>
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.CreditCard.typename,
                "expirationDate": expirationDate,
                "id": id,
                "lastFour": lastFour,
                "type": type,
              ],
              fulfilledFragments: [
                ObjectIdentifier(FetchUserStoredCardsQuery.Data.Me.StoredCards.Node.self)
              ]
            ))
          }
        }
      }
    }
  }
}
