// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RichTextExampleProjectsQuery: GraphQLQuery {
  public static let operationName: String = "RichTextExampleProjectsQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query RichTextExampleProjectsQuery { projects(recommended: true, first: 10) { __typename nodes { __typename id name storyRichText { __typename ...RichTextComponentFragment } } } }"#,
      fragments: [RichTextComponentFragment.self, RichTextItemFragment.self]
    ))

  public init() {}

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("projects", Projects?.self, arguments: [
        "recommended": true,
        "first": 10
      ]),
    ] }

    /// Get some projects
    public var projects: Projects? { __data["projects"] }

    public init(
      projects: Projects? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "projects": projects._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextExampleProjectsQuery.Data.self)
        ]
      ))
    }

    /// Projects
    ///
    /// Parent Type: `ProjectsConnectionWithTotalCount`
    public struct Projects: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectsConnectionWithTotalCount }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node?]?.self),
      ] }

      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

      public init(
        nodes: [Node?]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.ProjectsConnectionWithTotalCount.typename,
            "nodes": nodes._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextExampleProjectsQuery.Data.Projects.self)
          ]
        ))
      }

      /// Projects.Node
      ///
      /// Parent Type: `Project`
      public struct Node: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", GraphAPI.ID.self),
          .field("name", String.self),
          .field("storyRichText", StoryRichText.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// The project's name.
        public var name: String { __data["name"] }
        /// Return an itemized version of the story. This feature is in BETA: types can change anytime!
        public var storyRichText: StoryRichText { __data["storyRichText"] }

        public init(
          id: GraphAPI.ID,
          name: String,
          storyRichText: StoryRichText
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Project.typename,
              "id": id,
              "name": name,
              "storyRichText": storyRichText._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RichTextExampleProjectsQuery.Data.Projects.Node.self)
            ]
          ))
        }

        /// Projects.Node.StoryRichText
        ///
        /// Parent Type: `RichTextComponent`
        public struct StoryRichText: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextComponent }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(RichTextComponentFragment.self),
          ] }

          public var items: [Item] { __data["items"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextComponentFragment: RichTextComponentFragment { _toFragment() }
          }

          public init(
            items: [Item]
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextComponent.typename,
                "items": items._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextExampleProjectsQuery.Data.Projects.Node.StoryRichText.self),
                ObjectIdentifier(RichTextComponentFragment.self)
              ]
            ))
          }

          public typealias Item = RichTextComponentFragment.Item
        }
      }
    }
  }
}
