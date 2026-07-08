// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ProjectVideoFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ProjectVideoFragment on Video { __typename id videoSources { __typename high { __typename src } hls { __typename src } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Video }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", GraphAPI.ID.self),
    .field("videoSources", VideoSources?.self),
  ] }

  public var id: GraphAPI.ID { __data["id"] }
  /// A video's sources (hls, high, base)
  public var videoSources: VideoSources? { __data["videoSources"] }

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
        ObjectIdentifier(ProjectVideoFragment.self)
      ]
    ))
  }

  /// VideoSources
  ///
  /// Parent Type: `VideoSources`
  public struct VideoSources: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.VideoSources }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("high", High?.self),
      .field("hls", Hls?.self),
    ] }

    public var high: High? { __data["high"] }
    public var hls: Hls? { __data["hls"] }

    public init(
      high: High? = nil,
      hls: Hls? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.VideoSources.typename,
          "high": high._fieldData,
          "hls": hls._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ProjectVideoFragment.VideoSources.self)
        ]
      ))
    }

    /// VideoSources.High
    ///
    /// Parent Type: `VideoSourceInfo`
    public struct High: GraphAPI.SelectionSet {
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
            ObjectIdentifier(ProjectVideoFragment.VideoSources.High.self)
          ]
        ))
      }
    }

    /// VideoSources.Hls
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
            ObjectIdentifier(ProjectVideoFragment.VideoSources.Hls.self)
          ]
        ))
      }
    }
  }
}
