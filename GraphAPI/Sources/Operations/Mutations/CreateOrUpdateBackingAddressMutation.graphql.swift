// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateOrUpdateBackingAddressMutation: GraphQLMutation {
  public static let operationName: String = "CreateOrUpdateBackingAddress"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateOrUpdateBackingAddress($input: CreateOrUpdateBackingAddressInput!) { createOrUpdateBackingAddress(input: $input) { __typename success } }"#
    ))

  public var input: CreateOrUpdateBackingAddressInput

  public init(input: CreateOrUpdateBackingAddressInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createOrUpdateBackingAddress", CreateOrUpdateBackingAddress?.self, arguments: ["input": .variable("input")]),
    ] }

    public var createOrUpdateBackingAddress: CreateOrUpdateBackingAddress? { __data["createOrUpdateBackingAddress"] }

    /// CreateOrUpdateBackingAddress
    ///
    /// Parent Type: `CreateOrUpdateBackingAddressPayload`
    public struct CreateOrUpdateBackingAddress: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreateOrUpdateBackingAddressPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("success", Bool.self),
      ] }

      public var success: Bool { __data["success"] }
    }
  }
}
