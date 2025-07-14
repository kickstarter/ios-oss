// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateUserAccountMutation: GraphQLMutation {
  public static let operationName: String = "UpdateUserAccount"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateUserAccount($input: UpdateUserAccountInput!) { updateUserAccount(input: $input) { __typename clientMutationId } }"#
    ))

  public var input: UpdateUserAccountInput

  public init(input: UpdateUserAccountInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateUserAccount", UpdateUserAccount?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Update user account
    public var updateUserAccount: UpdateUserAccount? { __data["updateUserAccount"] }

    public init(
      updateUserAccount: UpdateUserAccount? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "updateUserAccount": updateUserAccount._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UpdateUserAccountMutation.Data.self)
        ]
      ))
    }

    /// UpdateUserAccount
    ///
    /// Parent Type: `UpdateUserAccountPayload`
    public struct UpdateUserAccount: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UpdateUserAccountPayload }
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
            "__typename": GraphAPI.Objects.UpdateUserAccountPayload.typename,
            "clientMutationId": clientMutationId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(UpdateUserAccountMutation.Data.UpdateUserAccount.self)
          ]
        ))
      }
    }
  }
}
