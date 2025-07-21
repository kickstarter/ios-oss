// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateFlaggingMutation: GraphQLMutation {
  public static let operationName: String = "createFlagging"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation createFlagging($input: CreateFlaggingInput!) { createFlagging(input: $input) { __typename clientMutationId } }"#
    ))

  public var input: CreateFlaggingInput

  public init(input: CreateFlaggingInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createFlagging", CreateFlagging?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Create a flagging (report) of a piece flaggable content.
    public var createFlagging: CreateFlagging? { __data["createFlagging"] }

    public init(
      createFlagging: CreateFlagging? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "createFlagging": createFlagging._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CreateFlaggingMutation.Data.self)
        ]
      ))
    }

    /// CreateFlagging
    ///
    /// Parent Type: `CreateFlaggingPayload`
    public struct CreateFlagging: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreateFlaggingPayload }
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
            "__typename": GraphAPI.Objects.CreateFlaggingPayload.typename,
            "clientMutationId": clientMutationId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CreateFlaggingMutation.Data.CreateFlagging.self)
          ]
        ))
      }
    }
  }
}
