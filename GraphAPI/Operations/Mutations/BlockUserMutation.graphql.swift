// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class BlockUserMutation: GraphQLMutation {
  public static let operationName: String = "blockUser"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation blockUser($input: BlockUserInput!) { blockUser(input: $input) { __typename success } }"#
    ))

  public var input: BlockUserInput

  public init(input: BlockUserInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("blockUser", BlockUser?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Block a user
    public var blockUser: BlockUser? { __data["blockUser"] }

    public init(
      blockUser: BlockUser? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "blockUser": blockUser._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(BlockUserMutation.Data.self)
        ]
      ))
    }

    /// BlockUser
    ///
    /// Parent Type: `BlockUserPayload`
    public struct BlockUser: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.BlockUserPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("success", Bool.self),
      ] }

      public var success: Bool { __data["success"] }

      public init(
        success: Bool
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.BlockUserPayload.typename,
            "success": success,
          ],
          fulfilledFragments: [
            ObjectIdentifier(BlockUserMutation.Data.BlockUser.self)
          ]
        ))
      }
    }
  }
}
