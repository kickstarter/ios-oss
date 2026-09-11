// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class RichTextExampleProjectBySlugQuery: GraphQLQuery {
  public static let operationName: String = "RichTextExampleProjectBySlugQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query RichTextExampleProjectBySlugQuery($slug: String!, $storyRichText: Boolean!) { project(slug: $slug) { __typename id name storyRichText { __typename ...RichTextComponentFragment } } }"#,
      fragments: [RichTextComponentFragment.self, RichTextItemFragment.self]
    ))

  public var slug: String
  public var storyRichText: Bool

  public init(
    slug: String,
    storyRichText: Bool
  ) {
    self.slug = slug
    self.storyRichText = storyRichText
  }

  public var __variables: Variables? { [
    "slug": slug,
    "storyRichText": storyRichText
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: ["slug": .variable("slug")]),
    ] }

    /// Fetches a project given its slug or pid.
    public var project: Project? { __data["project"] }

    public init(
      project: Project? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "project": project._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextExampleProjectBySlugQuery.Data.self)
        ]
      ))
    }

    /// Project
    ///
    /// Parent Type: `Project`
    public struct Project: GraphAPI.SelectionSet {
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
            ObjectIdentifier(RichTextExampleProjectBySlugQuery.Data.Project.self)
          ]
        ))
      }

      /// Project.StoryRichText
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

        public var items: [Item]? { __data["items"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var richTextComponentFragment: RichTextComponentFragment { _toFragment() }
        }

        public init(
          items: [Item]? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.RichTextComponent.typename,
              "items": items._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RichTextExampleProjectBySlugQuery.Data.Project.StoryRichText.self),
              ObjectIdentifier(RichTextComponentFragment.self)
            ]
          ))
        }

        public typealias Item = RichTextComponentFragment.Item
      }
    }
  }
}
