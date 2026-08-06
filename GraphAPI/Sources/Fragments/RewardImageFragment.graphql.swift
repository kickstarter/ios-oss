// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RewardImageFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RewardImageFragment on Reward { __typename image { __typename altText url(width: 1024) } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Reward }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("image", Image?.self),
  ] }

  /// The reward image.
  public var image: Image? { __data["image"] }

  public init(
    image: Image? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Reward.typename,
        "image": image._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(RewardImageFragment.self)
      ]
    ))
  }

  /// Image
  ///
  /// Parent Type: `Photo`
  public struct Image: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Photo }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("altText", String.self),
      .field("url", String.self, arguments: ["width": 1024]),
    ] }

    /// Alt text on the image
    public var altText: String { __data["altText"] }
    /// URL of the photo
    public var url: String { __data["url"] }

    public init(
      altText: String,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.Photo.typename,
          "altText": altText,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RewardImageFragment.Image.self)
        ]
      ))
    }
  }
}
