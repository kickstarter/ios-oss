// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectVideoFeedFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectVideoFeedFragment on Project { __typename id pid name slug percentFunded deadlineAt launchedAt backersCount pledged { __typename amount } creator { __typename name imageUrl(blur: false, width: 200) } category { __typename name } lastUploadedVerticalVideo { __typename id previewImageUrl videoSources { __typename hls { __typename src } } } }"#
  }

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
        ObjectIdentifier(ProjectVideoFeedFragment.self)
      ]
    ))
  }

  /// Pledged
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
          ObjectIdentifier(ProjectVideoFeedFragment.Pledged.self)
        ]
      ))
    }
  }

  /// Creator
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
          ObjectIdentifier(ProjectVideoFeedFragment.Creator.self)
        ]
      ))
    }
  }

  /// Category
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
          ObjectIdentifier(ProjectVideoFeedFragment.Category.self)
        ]
      ))
    }
  }

  /// LastUploadedVerticalVideo
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
          ObjectIdentifier(ProjectVideoFeedFragment.LastUploadedVerticalVideo.self)
        ]
      ))
    }

    /// LastUploadedVerticalVideo.VideoSources
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
            ObjectIdentifier(ProjectVideoFeedFragment.LastUploadedVerticalVideo.VideoSources.self)
          ]
        ))
      }

      /// LastUploadedVerticalVideo.VideoSources.Hls
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
              ObjectIdentifier(ProjectVideoFeedFragment.LastUploadedVerticalVideo.VideoSources.Hls.self)
            ]
          ))
        }
      }
    }
  }
}
