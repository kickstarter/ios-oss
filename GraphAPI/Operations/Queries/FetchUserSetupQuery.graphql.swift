// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FetchUserSetupQuery: GraphQLQuery {
  public static let operationName: String = "FetchUserSetup"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FetchUserSetup { me { __typename ...UserEmailFragment ...UserFeaturesFragment ...PPOUserSetupFragment } }"#,
      fragments: [PPOUserSetupFragment.self, UserEmailFragment.self, UserFeaturesFragment.self]
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
          ObjectIdentifier(FetchUserSetupQuery.Data.self)
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
        .fragment(UserEmailFragment.self),
        .fragment(UserFeaturesFragment.self),
        .fragment(PPOUserSetupFragment.self),
      ] }

      /// A user's email address.
      public var email: String? { __data["email"] }
      public var enabledFeatures: [GraphQLEnum<GraphAPI.Feature>] { __data["enabledFeatures"] }
      /// Whether backer has any action in PPO
      public var ppoHasAction: Bool? { __data["ppoHasAction"] }
      /// Count of pledges with pending action
      public var backingActionCount: Int? { __data["backingActionCount"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var userEmailFragment: UserEmailFragment { _toFragment() }
        public var userFeaturesFragment: UserFeaturesFragment { _toFragment() }
        public var pPOUserSetupFragment: PPOUserSetupFragment { _toFragment() }
      }

      public init(
        email: String? = nil,
        enabledFeatures: [GraphQLEnum<GraphAPI.Feature>],
        ppoHasAction: Bool? = nil,
        backingActionCount: Int? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.User.typename,
            "email": email,
            "enabledFeatures": enabledFeatures,
            "ppoHasAction": ppoHasAction,
            "backingActionCount": backingActionCount,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FetchUserSetupQuery.Data.Me.self),
            ObjectIdentifier(UserEmailFragment.self),
            ObjectIdentifier(UserFeaturesFragment.self),
            ObjectIdentifier(PPOUserSetupFragment.self)
          ]
        ))
      }
    }
  }
}
