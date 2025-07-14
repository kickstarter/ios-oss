// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateAttributionEventMutation: GraphQLMutation {
  public static let operationName: String = "createAttributionEvent"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation createAttributionEvent($input: CreateAttributionEventInput!) { createAttributionEvent(input: $input) { __typename successful } }"#
    ))

  public var input: CreateAttributionEventInput

  public init(input: CreateAttributionEventInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createAttributionEvent", CreateAttributionEvent?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Creates an attribution event. Specifying a project will pass the project properties for attribution events. Sending this request as a logged-in user passes that user's properties as well. Any passed-in property with the same name overwrites the generated properties.
    public var createAttributionEvent: CreateAttributionEvent? { __data["createAttributionEvent"] }

    public init(
      createAttributionEvent: CreateAttributionEvent? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "createAttributionEvent": createAttributionEvent._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CreateAttributionEventMutation.Data.self)
        ]
      ))
    }

    /// CreateAttributionEvent
    ///
    /// Parent Type: `CreateAttributionEventPayload`
    public struct CreateAttributionEvent: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.CreateAttributionEventPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("successful", Bool.self),
      ] }

      public var successful: Bool { __data["successful"] }

      public init(
        successful: Bool
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.CreateAttributionEventPayload.typename,
            "successful": successful,
          ],
          fulfilledFragments: [
            ObjectIdentifier(CreateAttributionEventMutation.Data.CreateAttributionEvent.self)
          ]
        ))
      }
    }
  }
}
