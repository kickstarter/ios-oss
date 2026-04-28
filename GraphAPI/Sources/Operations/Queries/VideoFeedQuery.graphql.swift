// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class VideoFeedQuery: GraphQLQuery {
  public static let operationName: String = "VideoFeed"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query VideoFeed($first: Int!, $after: String, $categoryId: String) { videoFeed(first: $first, after: $after, categoryId: $categoryId) { __typename pageInfo { __typename hasNextPage endCursor hasPreviousPage startCursor } nodes { __typename badges { __typename type text icon } project { __typename id pid name slug percentFunded deadlineAt launchedAt backersCount pledged { __typename amount } creator { __typename name imageUrl(blur: false, width: 200) } category { __typename name } lastUploadedVerticalVideo { __typename id previewImageUrl videoSources { __typename hls { __typename src } } } } } } }"#
    ))

  public var first: Int
  public var after: GraphQLNullable<String>
  public var categoryId: GraphQLNullable<String>

  public init(
    first: Int,
    after: GraphQLNullable<String>,
    categoryId: GraphQLNullable<String>
  ) {
    self.first = first
    self.after = after
    self.categoryId = categoryId
  }

  public var __variables: Variables? { [
    "first": first,
    "after": after,
    "categoryId": categoryId
  ] }

  public struct Data: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("videoFeed", VideoFeed?.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after"),
        "categoryId": .variable("categoryId")
      ]),
    ] }

    /// Paginated feed of live projects with vertical videos, for the mobile discovery experience.
    public var videoFeed: VideoFeed? { __data["videoFeed"] }

    public init(
      videoFeed: VideoFeed? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Query.typename,
          "videoFeed": videoFeed._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(VideoFeedQuery.Data.self)
        ]
      ))
    }

    /// VideoFeed
    ///
    /// Parent Type: `VideoFeedConnection`
    public struct VideoFeed: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoFeedConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("pageInfo", PageInfo.self),
        .field("nodes", [Node?]?.self),
      ] }

      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }

      public init(
        pageInfo: PageInfo,
        nodes: [Node?]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.VideoFeedConnection.typename,
            "pageInfo": pageInfo._fieldData,
            "nodes": nodes._fieldData,
          ],
          fulfilledFragments: [
            ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.self)
          ]
        ))
      }

      /// VideoFeed.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("hasNextPage", Bool.self),
          .field("endCursor", String?.self),
          .field("hasPreviousPage", Bool.self),
          .field("startCursor", String?.self),
        ] }

        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? { __data["startCursor"] }

        public init(
          hasNextPage: Bool,
          endCursor: String? = nil,
          hasPreviousPage: Bool,
          startCursor: String? = nil
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.PageInfo.typename,
              "hasNextPage": hasNextPage,
              "endCursor": endCursor,
              "hasPreviousPage": hasPreviousPage,
              "startCursor": startCursor,
            ],
            fulfilledFragments: [
              ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.PageInfo.self)
            ]
          ))
        }
      }

      /// VideoFeed.Node
      ///
      /// Parent Type: `VideoFeedItem`
      public struct Node: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoFeedItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("badges", [Badge].self),
          .field("project", Project.self),
        ] }

        /// Computed badges for this project (e.g. "Project We Love", "3 days left")
        public var badges: [Badge] { __data["badges"] }
        /// The project associated with this feed item
        public var project: Project { __data["project"] }

        public init(
          badges: [Badge],
          project: Project
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": GraphAPI.Objects.VideoFeedItem.typename,
              "badges": badges._fieldData,
              "project": project._fieldData,
            ],
            fulfilledFragments: [
              ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.self)
            ]
          ))
        }

        /// VideoFeed.Node.Badge
        ///
        /// Parent Type: `Badge`
        public struct Badge: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Badge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("type", GraphQLEnum<GraphAPI.BadgeTypeEnum>.self),
            .field("text", String.self),
            .field("icon", String?.self),
          ] }

          /// The category of badge
          public var type: GraphQLEnum<GraphAPI.BadgeTypeEnum> { __data["type"] }
          /// Human-readable badge label (e.g. "3 days left", "Project We Love")
          public var text: String { __data["text"] }
          /// Optional icon identifier for the badge (e.g. "heart", "clock", "fire")
          public var icon: String? { __data["icon"] }

          public init(
            type: GraphQLEnum<GraphAPI.BadgeTypeEnum>,
            text: String,
            icon: String? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Badge.typename,
                "type": type,
                "text": text,
                "icon": icon,
              ],
              fulfilledFragments: [
                ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Badge.self)
              ]
            ))
          }
        }

        /// VideoFeed.Node.Project
        ///
        /// Parent Type: `Project`
        public struct Project: GraphAPI.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", GraphAPI.ID.self),
            .field("pid", Int.self),
            .field("name", String.self),
            .field("slug", String.self),
            .field("percentFunded", Int.self),
            .field("deadlineAt", GraphAPI.DateTime?.self),
            .field("launchedAt", GraphAPI.DateTime?.self),
            .field("backersCount", Int.self),
            .field("pledged", Pledged.self),
            .field("creator", Creator?.self),
            .field("category", Category?.self),
            .field("lastUploadedVerticalVideo", LastUploadedVerticalVideo?.self),
          ] }

          public var id: GraphAPI.ID { __data["id"] }
          /// The project's pid.
          public var pid: Int { __data["pid"] }
          /// The project's name.
          public var name: String { __data["name"] }
          /// The project's unique URL identifier.
          public var slug: String { __data["slug"] }
          /// What percent the project has towards meeting its funding goal.
          public var percentFunded: Int { __data["percentFunded"] }
          /// When is the project scheduled to end?
          public var deadlineAt: GraphAPI.DateTime? { __data["deadlineAt"] }
          /// When the project launched
          public var launchedAt: GraphAPI.DateTime? { __data["launchedAt"] }
          /// Total backers for the project
          public var backersCount: Int { __data["backersCount"] }
          /// How much money is pledged to the project.
          public var pledged: Pledged { __data["pledged"] }
          /// The project's creator.
          public var creator: Creator? { __data["creator"] }
          /// The project's category.
          public var category: Category? { __data["category"] }
          /// A project's last uploaded vertical video, if it's processing, or the current vertical video.
          public var lastUploadedVerticalVideo: LastUploadedVerticalVideo? { __data["lastUploadedVerticalVideo"] }

          public init(
            id: GraphAPI.ID,
            pid: Int,
            name: String,
            slug: String,
            percentFunded: Int,
            deadlineAt: GraphAPI.DateTime? = nil,
            launchedAt: GraphAPI.DateTime? = nil,
            backersCount: Int,
            pledged: Pledged,
            creator: Creator? = nil,
            category: Category? = nil,
            lastUploadedVerticalVideo: LastUploadedVerticalVideo? = nil
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.Project.typename,
                "id": id,
                "pid": pid,
                "name": name,
                "slug": slug,
                "percentFunded": percentFunded,
                "deadlineAt": deadlineAt,
                "launchedAt": launchedAt,
                "backersCount": backersCount,
                "pledged": pledged._fieldData,
                "creator": creator._fieldData,
                "category": category._fieldData,
                "lastUploadedVerticalVideo": lastUploadedVerticalVideo._fieldData,
              ],
              fulfilledFragments: [
                ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.self)
              ]
            ))
          }

          /// VideoFeed.Node.Project.Pledged
          ///
          /// Parent Type: `Money`
          public struct Pledged: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Money }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("amount", String?.self),
            ] }

            /// Floating-point numeric value of monetary amount represented as a string
            public var amount: String? { __data["amount"] }

            public init(
              amount: String? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Money.typename,
                  "amount": amount,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.Pledged.self)
                ]
              ))
            }
          }

          /// VideoFeed.Node.Project.Creator
          ///
          /// Parent Type: `User`
          public struct Creator: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.User }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", String.self),
              .field("imageUrl", String.self, arguments: [
                "blur": false,
                "width": 200
              ]),
            ] }

            /// The user's provided name.
            public var name: String { __data["name"] }
            /// The user's avatar.
            public var imageUrl: String { __data["imageUrl"] }

            public init(
              name: String,
              imageUrl: String
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.User.typename,
                  "name": name,
                  "imageUrl": imageUrl,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.Creator.self)
                ]
              ))
            }
          }

          /// VideoFeed.Node.Project.Category
          ///
          /// Parent Type: `Category`
          public struct Category: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Category }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("name", String.self),
            ] }

            /// Category name.
            public var name: String { __data["name"] }

            public init(
              name: String
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Category.typename,
                  "name": name,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.Category.self)
                ]
              ))
            }
          }

          /// VideoFeed.Node.Project.LastUploadedVerticalVideo
          ///
          /// Parent Type: `Video`
          public struct LastUploadedVerticalVideo: GraphAPI.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", GraphAPI.ID.self),
              .field("previewImageUrl", String?.self),
              .field("videoSources", VideoSources?.self),
            ] }

            public var id: GraphAPI.ID { __data["id"] }
            /// Preview image url for the video
            public var previewImageUrl: String? { __data["previewImageUrl"] }
            /// A video's sources (hls, high, base)
            public var videoSources: VideoSources? { __data["videoSources"] }

            public init(
              id: GraphAPI.ID,
              previewImageUrl: String? = nil,
              videoSources: VideoSources? = nil
            ) {
              self.init(_dataDict: DataDict(
                data: [
                  "__typename": GraphAPI.Objects.Video.typename,
                  "id": id,
                  "previewImageUrl": previewImageUrl,
                  "videoSources": videoSources._fieldData,
                ],
                fulfilledFragments: [
                  ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.LastUploadedVerticalVideo.self)
                ]
              ))
            }

            /// VideoFeed.Node.Project.LastUploadedVerticalVideo.VideoSources
            ///
            /// Parent Type: `VideoSources`
            public struct VideoSources: GraphAPI.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSources }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("hls", Hls?.self),
              ] }

              public var hls: Hls? { __data["hls"] }

              public init(
                hls: Hls? = nil
              ) {
                self.init(_dataDict: DataDict(
                  data: [
                    "__typename": GraphAPI.Objects.VideoSources.typename,
                    "hls": hls._fieldData,
                  ],
                  fulfilledFragments: [
                    ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.LastUploadedVerticalVideo.VideoSources.self)
                  ]
                ))
              }

              /// VideoFeed.Node.Project.LastUploadedVerticalVideo.VideoSources.Hls
              ///
              /// Parent Type: `VideoSourceInfo`
              public struct Hls: GraphAPI.SelectionSet {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSourceInfo }
                public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .field("src", String?.self),
                ] }

                public var src: String? { __data["src"] }

                public init(
                  src: String? = nil
                ) {
                  self.init(_dataDict: DataDict(
                    data: [
                      "__typename": GraphAPI.Objects.VideoSourceInfo.typename,
                      "src": src,
                    ],
                    fulfilledFragments: [
                      ObjectIdentifier(VideoFeedQuery.Data.VideoFeed.Node.Project.LastUploadedVerticalVideo.VideoSources.Hls.self)
                    ]
                  ))
                }
              }
            }
          }
        }
      }
    }
  }
}
