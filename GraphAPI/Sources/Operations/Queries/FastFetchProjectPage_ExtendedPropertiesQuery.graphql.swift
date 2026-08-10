// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FastFetchProjectPage_ExtendedPropertiesQuery: GraphQLQuery {
  public static let operationName: String = "FastFetchProjectPage_ExtendedPropertiesQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FastFetchProjectPage_ExtendedPropertiesQuery($projectId: Int, $slug: String) { project(pid: $projectId, slug: $slug) { __typename ...ExtendedProjectPropertiesFragment video { __typename ...ProjectVideoFragment } flagging { __typename kind } } }"#,
      fragments: [ExtendedProjectPropertiesFragment.self, ProjectVideoFragment.self, RichTextComponentFragment.self, RichTextItemFragment.self]
    ))

  public var projectId: GraphQLNullable<Int>
  public var slug: GraphQLNullable<String>

  public init(
    projectId: GraphQLNullable<Int>,
    slug: GraphQLNullable<String>
  ) {
    self.projectId = projectId
    self.slug = slug
  }

  public var __variables: Variables? { [
    "projectId": projectId,
    "slug": slug
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("project", Project?.self, arguments: [
        "pid": .variable("projectId"),
        "slug": .variable("slug")
      ]),
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
          ObjectIdentifier(FastFetchProjectPage_ExtendedPropertiesQuery.Data.self)
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
        .field("video", Video?.self),
        .field("flagging", Flagging?.self),
        .fragment(ExtendedProjectPropertiesFragment.self),
      ] }

      /// A project video.
      public var video: Video? { __data["video"] }
      /// A report by the current user for the project.
      public var flagging: Flagging? { __data["flagging"] }
      public var aiDisclosure: AiDisclosure? { __data["aiDisclosure"] }
      /// The environmental commitments of the project.
      public var environmentalCommitments: [EnvironmentalCommitment?]? { __data["environmentalCommitments"] }
      /// List of FAQs of a project
      public var faqs: Faqs? { __data["faqs"] }
      /// The min pledge amount for a single reward tier.
      public var minPledge: Int { __data["minPledge"] }
      /// The text of the currently applied project notice, empty if there is no notice
      public var projectNotice: String? { __data["projectNotice"] }
      /// Potential hurdles to project completion.
      public var risks: String { __data["risks"] }
      /// The story behind the project, parsed for presentation.
      public var story: GraphAPI.HTML { __data["story"] }
      /// Return an itemized version of the story. This feature is in BETA: types can change anytime!
      public var storyRichText: StoryRichText { __data["storyRichText"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var extendedProjectPropertiesFragment: ExtendedProjectPropertiesFragment { _toFragment() }
      }

      public init(
        video: Video? = nil,
        flagging: Flagging? = nil,
        aiDisclosure: AiDisclosure? = nil,
        environmentalCommitments: [EnvironmentalCommitment?]? = nil,
        faqs: Faqs? = nil,
        minPledge: Int,
        projectNotice: String? = nil,
        risks: String,
        story: GraphAPI.HTML,
        storyRichText: StoryRichText
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Project.typename,
            "video": video._fieldData,
            "flagging": flagging._fieldData,
            "aiDisclosure": aiDisclosure._fieldData,
            "environmentalCommitments": environmentalCommitments._fieldData,
            "faqs": faqs._fieldData,
            "minPledge": minPledge,
            "projectNotice": projectNotice,
            "risks": risks,
            "story": story,
            "storyRichText": storyRichText._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(FastFetchProjectPage_ExtendedPropertiesQuery.Data.Project.self),
            ObjectIdentifier(ExtendedProjectPropertiesFragment.self)
          ]
        ))
      }

      /// Project.Video
      ///
      /// Parent Type: `Video`
      public struct Video: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ProjectVideoFragment.self),
        ] }

        public var id: GraphAPI.ID { __data["id"] }
        /// A video's sources (hls, high, base)
        public var videoSources: VideoSources? { __data["videoSources"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var projectVideoFragment: ProjectVideoFragment { _toFragment() }
        }

        public init(
          id: GraphAPI.ID,
          videoSources: VideoSources? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Video.typename,
              "id": id,
              "videoSources": videoSources._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FastFetchProjectPage_ExtendedPropertiesQuery.Data.Project.Video.self),
              ObjectIdentifier(ProjectVideoFragment.self)
            ]
          ))
        }

        public typealias VideoSources = ProjectVideoFragment.VideoSources
      }

      /// Project.Flagging
      ///
      /// Parent Type: `Flagging`
      public struct Flagging: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Flagging }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("kind", GraphQLEnum<GraphAPI.FlaggingKind>?.self),
        ] }

        /// The general reason for the flagging.
        public var kind: GraphQLEnum<GraphAPI.FlaggingKind>? { __data["kind"] }

        public init(
          kind: GraphQLEnum<GraphAPI.FlaggingKind>? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.Flagging.typename,
              "kind": kind,
            ],
            fulfilledFragments: [
              ObjectIdentifier(FastFetchProjectPage_ExtendedPropertiesQuery.Data.Project.Flagging.self)
            ]
          ))
        }
      }

      public typealias AiDisclosure = ExtendedProjectPropertiesFragment.AiDisclosure

      public typealias EnvironmentalCommitment = ExtendedProjectPropertiesFragment.EnvironmentalCommitment

      public typealias Faqs = ExtendedProjectPropertiesFragment.Faqs

      /// Project.StoryRichText
      ///
      /// Parent Type: `RichTextComponent`
      public struct StoryRichText: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextComponent }

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
              ObjectIdentifier(FastFetchProjectPage_ExtendedPropertiesQuery.Data.Project.StoryRichText.self),
              ObjectIdentifier(ExtendedProjectPropertiesFragment.StoryRichText.self),
              ObjectIdentifier(RichTextComponentFragment.self)
            ]
          ))
        }

        public typealias Item = RichTextComponentFragment.Item
      }
    }
  }
}
