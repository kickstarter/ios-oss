// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UpdateBackerCompletedMutation: GraphQLMutation {
  public static let operationName: String = "UpdateBackerCompleted"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UpdateBackerCompleted($input: UpdateBackerCompletedInput!) { updateBackerCompleted(input: $input) { __typename backing { __typename backerCompleted } } }"#
    ))

  public var input: UpdateBackerCompletedInput

  public init(input: UpdateBackerCompletedInput) {
    self.input = input
  }

  public var __variables: Variables? { ["input": input] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("updateBackerCompleted", UpdateBackerCompleted?.self, arguments: ["input": .variable("input")]),
    ] }

    /// Update the backing completed at field with a backing_completed toggle
    public var updateBackerCompleted: UpdateBackerCompleted? { __data["updateBackerCompleted"] }

    public init(
      updateBackerCompleted: UpdateBackerCompleted? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Mutation.typename,
          "updateBackerCompleted": updateBackerCompleted._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(UpdateBackerCompletedMutation.Data.self)
        ]
      ))
    }

    /// UpdateBackerCompleted
    ///
    /// Parent Type: `UpdateBackerCompletedPayload`
    public struct UpdateBackerCompleted: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.UpdateBackerCompletedPayload }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("backing", Backing?.self),
      ] }

      public var backing: Backing? { __data["backing"] }

      public init(
        backing: Backing? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.UpdateBackerCompletedPayload.typename,
            "backing": backing._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(UpdateBackerCompletedMutation.Data.UpdateBackerCompleted.self)
          ]
        ))
      }

      /// UpdateBackerCompleted.Backing
      ///
      /// Parent Type: `Backing`
      public struct Backing: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Backing }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("backerCompleted", Bool.self),
        ] }

        /// If the backer_completed_at is set or not
        public var backerCompleted: Bool { __data["backerCompleted"] }

        public init(
          backerCompleted: Bool
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Backing.typename,
              "backerCompleted": backerCompleted,
            ],
            fulfilledFragments: [
              ObjectIdentifier(UpdateBackerCompletedMutation.Data.UpdateBackerCompleted.Backing.self)
            ]
          ))
        }
      }
    }
  }
}
