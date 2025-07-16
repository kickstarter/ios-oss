// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateSetupIntentMutation: GraphQLMutation {
  public static let operationName: String = "CreateSetupIntent"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation CreateSetupIntent($input: CreateSetupIntentInput!) { createSetupIntent(input: $input) { __typename clientSecret } }"#
    ))

  public var input: CreateSetupIntentInput

  public init(input: CreateSetupIntentInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createSetupIntent", CreateSetupIntent?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Create a Stripe SetupIntent in order to render new Stripe Elements
    public var createSetupIntent: CreateSetupIntent? { __data["createSetupIntent"] }

    public init(
      createSetupIntent: CreateSetupIntent? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "createSetupIntent": createSetupIntent._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CreateSetupIntentMutation.Data.self)
        ]
      ))
    }

    /// CreateSetupIntent
    ///
    /// Parent Type: `CreateSetupIntentPayload`
    public struct CreateSetupIntent: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreateSetupIntentPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("clientSecret", String.self),
      ] }

      public var clientSecret: String { __data["clientSecret"] }

      public init(
        clientSecret: String
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.CreateSetupIntentPayload.typename,
            "clientSecret": clientSecret,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CreateSetupIntentMutation.Data.CreateSetupIntent.self)
          ]
        ))
      }
    }
  }
}
