// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FlaggingOptionsQuery: GraphQLQuery {
  public static let operationName: String = "FlaggingOptions"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FlaggingOptions($contentType: FlaggingContent!) { flaggingOptions(contentType: $contentType) { __typename id parentId kind nodeType title subtitle placeholder } }"#
    ))

  public var contentType: GraphQLEnum<FlaggingContent>

  public init(contentType: GraphQLEnum<FlaggingContent>) {
    self.contentType = contentType
  }

  public var __variables: Variables? { ["contentType": contentType] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("flaggingOptions", [FlaggingOption].self, arguments: ["contentType": .variable("contentType")]),
    ] }

    /// Fetches flagging kinds given a content type
    public var flaggingOptions: [FlaggingOption] { __data["flaggingOptions"] }

    public init(
      flaggingOptions: [FlaggingOption]
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "flaggingOptions": flaggingOptions._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(FlaggingOptionsQuery.Data.self)
        ]
      ))
    }

    /// FlaggingOption
    ///
    /// Parent Type: `FlaggingNode`
    public struct FlaggingOption: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.FlaggingNode }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("parentId", String?.self),
        .field("kind", GraphQLEnum<GraphAPI.NonDeprecatedFlaggingKind>?.self),
        .field("nodeType", GraphQLEnum<GraphAPI.FlaggingNodeKind>.self),
        .field("title", String.self),
        .field("subtitle", String?.self),
        .field("placeholder", String?.self),
      ] }

      public var id: String { __data["id"] }
      public var parentId: String? { __data["parentId"] }
      public var kind: GraphQLEnum<GraphAPI.NonDeprecatedFlaggingKind>? { __data["kind"] }
      public var nodeType: GraphQLEnum<GraphAPI.FlaggingNodeKind> { __data["nodeType"] }
      public var title: String { __data["title"] }
      public var subtitle: String? { __data["subtitle"] }
      public var placeholder: String? { __data["placeholder"] }

      public init(
        id: String,
        parentId: String? = nil,
        kind: GraphQLEnum<GraphAPI.NonDeprecatedFlaggingKind>? = nil,
        nodeType: GraphQLEnum<GraphAPI.FlaggingNodeKind>,
        title: String,
        subtitle: String? = nil,
        placeholder: String? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.FlaggingNode.typename,
            "id": id,
            "parentId": parentId,
            "kind": kind,
            "nodeType": nodeType,
            "title": title,
            "subtitle": subtitle,
            "placeholder": placeholder,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FlaggingOptionsQuery.Data.FlaggingOption.self)
          ]
        ))
      }
    }
  }
}
