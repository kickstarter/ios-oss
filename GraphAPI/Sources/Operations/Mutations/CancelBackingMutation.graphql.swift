// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CancelBackingMutation: GraphQLMutation {
  public static let operationName: String = "cancelBacking"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation cancelBacking($input: CancelBackingInput!) { cancelBacking(input: $input) { __typename clientMutationId } }"#
    ))

  public var input: CancelBackingInput

  public init(input: CancelBackingInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("cancelBacking", CancelBacking?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Cancel a pledged backing
    public var cancelBacking: CancelBacking? { __data["cancelBacking"] }

    public init(
      cancelBacking: CancelBacking? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "cancelBacking": cancelBacking._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CancelBackingMutation.Data.self)
        ]
      ))
    }

    /// CancelBacking
    ///
    /// Parent Type: `CancelBackingPayload`
    public struct CancelBacking: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CancelBackingPayload }
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
            "__typename": GraphAPI.Objects.CancelBackingPayload.typename,
            "clientMutationId": clientMutationId,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CancelBackingMutation.Data.CancelBacking.self)
          ]
        ))
      }
    }
  }
}
