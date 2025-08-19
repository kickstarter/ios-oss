// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class SignInWithAppleMutation: GraphQLMutation {
  public static let operationName: String = "signInWithApple"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation signInWithApple($input: SignInWithAppleInput!) { signInWithApple(input: $input) { __typename apiAccessToken user { __typename uid } } }"#
    ))

  public var input: SignInWithAppleInput

  public init(input: SignInWithAppleInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("signInWithApple", SignInWithApple?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Signs in or sign up a user via the Sign in With Apple service
    public var signInWithApple: SignInWithApple? { __data["signInWithApple"] }

    public init(
      signInWithApple: SignInWithApple? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "signInWithApple": signInWithApple._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(SignInWithAppleMutation.Data.self)
        ]
      ))
    }

    /// SignInWithApple
    ///
    /// Parent Type: `SignInWithApplePayload`
    public struct SignInWithApple: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.SignInWithApplePayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("apiAccessToken", String?.self),
        .field("user", User?.self),
      ] }

      public var apiAccessToken: String? { __data["apiAccessToken"] }
      public var user: User? { __data["user"] }

      public init(
        apiAccessToken: String? = nil,
        user: User? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.SignInWithApplePayload.typename,
            "apiAccessToken": apiAccessToken,
            "user": user._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(SignInWithAppleMutation.Data.SignInWithApple.self)
          ]
        ))
      }

      /// SignInWithApple.User
      ///
      /// Parent Type: `User`
      public struct User: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("uid", String.self),
        ] }

        /// A user's uid
        public var uid: String { __data["uid"] }

        public init(
          uid: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.User.typename,
              "uid": uid,
            ],
            fulfilledFragments: [
              ObjectIdentifier(SignInWithAppleMutation.Data.SignInWithApple.User.self)
            ]
          ))
        }
      }
    }
  }
}
