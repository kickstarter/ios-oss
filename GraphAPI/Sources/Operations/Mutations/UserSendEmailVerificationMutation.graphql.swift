// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UserSendEmailVerificationMutation: GraphQLMutation {
  public static let operationName: String = "userSendEmailVerification"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation userSendEmailVerification($input: UserSendEmailVerificationInput!) { userSendEmailVerification(input: $input) { __typename clientMutationId } }"#
    ))

  public var input: UserSendEmailVerificationInput

  public init(input: UserSendEmailVerificationInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("userSendEmailVerification", UserSendEmailVerification?.self, arguments: ["input": .variable("input")]),
    ] }

    /// send email verification
    public var userSendEmailVerification: UserSendEmailVerification? { __data["userSendEmailVerification"] }

    public init(
      userSendEmailVerification: UserSendEmailVerification? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "userSendEmailVerification": userSendEmailVerification._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UserSendEmailVerificationMutation.Data.self)
        ]
      ))
    }

    /// UserSendEmailVerification
    ///
    /// Parent Type: `UserSendEmailVerificationPayload`
    public struct UserSendEmailVerification: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UserSendEmailVerificationPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientMutationId", String?.self),
      ] }

      /// A unique identifier for the client performing the mutation.
      public var clientMutationId: String? { __data["clientMutationId"] }

      public init(
        clientMutationId: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.UserSendEmailVerificationPayload.typename,
            "clientMutationId": clientMutationId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(UserSendEmailVerificationMutation.Data.UserSendEmailVerification.self)
          ]
        ))
      }
    }
  }
}
