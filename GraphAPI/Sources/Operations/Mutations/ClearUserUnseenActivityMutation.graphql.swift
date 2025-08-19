// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ClearUserUnseenActivityMutation: GraphQLMutation {
  public static let operationName: String = "clearUserUnseenActivity"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation clearUserUnseenActivity($input: ClearUserUnseenActivityInput!) { clearUserUnseenActivity(input: $input) { __typename clientMutationId activityIndicatorCount } }"#
    ))

  public var input: ClearUserUnseenActivityInput

  public init(input: ClearUserUnseenActivityInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("clearUserUnseenActivity", ClearUserUnseenActivity?.self, arguments: ["input": .variable("input")]),
    ] }

    public var clearUserUnseenActivity: ClearUserUnseenActivity? { __data["clearUserUnseenActivity"] }

    public init(
      clearUserUnseenActivity: ClearUserUnseenActivity? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "clearUserUnseenActivity": clearUserUnseenActivity._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ClearUserUnseenActivityMutation.Data.self)
        ]
      ))
    }

    /// ClearUserUnseenActivity
    ///
    /// Parent Type: `ClearUserUnseenActivityPayload`
    public struct ClearUserUnseenActivity: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ClearUserUnseenActivityPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientMutationId", String?.self),
        .field("activityIndicatorCount", Int.self),
      ] }

      /// A unique identifier for the client performing the mutation.
      public var clientMutationId: String? { __data["clientMutationId"] }
      public var activityIndicatorCount: Int { __data["activityIndicatorCount"] }

      public init(
        clientMutationId: String? = nil,
        activityIndicatorCount: Int
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.ClearUserUnseenActivityPayload.typename,
            "clientMutationId": clientMutationId,
            "activityIndicatorCount": activityIndicatorCount,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ClearUserUnseenActivityMutation.Data.ClearUserUnseenActivity.self)
          ]
        ))
      }
    }
  }
}
