// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateUserProfileMutation: GraphQLMutation {
  public static let operationName: String = "UpdateUserProfile"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateUserProfile($input: UpdateUserProfileInput!) { updateUserProfile(input: $input) { __typename clientMutationId } }"#
    ))

  public var input: UpdateUserProfileInput

  public init(input: UpdateUserProfileInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateUserProfile", UpdateUserProfile?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Update user's profile
    public var updateUserProfile: UpdateUserProfile? { __data["updateUserProfile"] }

    public init(
      updateUserProfile: UpdateUserProfile? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "updateUserProfile": updateUserProfile._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UpdateUserProfileMutation.Data.self)
        ]
      ))
    }

    /// UpdateUserProfile
    ///
    /// Parent Type: `UpdateUserProfilePayload`
    public struct UpdateUserProfile: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UpdateUserProfilePayload }
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
            "__typename": GraphAPI.Objects.UpdateUserProfilePayload.typename,
            "clientMutationId": clientMutationId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(UpdateUserProfileMutation.Data.UpdateUserProfile.self)
          ]
        ))
      }
    }
  }
}
