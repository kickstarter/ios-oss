// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RichTextItemFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RichTextItemFragment on RichTextItem { __typename ... on RichText { text link styles } ... on RichTextHeader { text link styles } ... on RichTextListItem { text link styles } ... on RichTextListOpen { _present } ... on RichTextListClose { _present } ... on RichTextPhoto { altText asset { __typename id } caption url } ... on RichTextAudio { altText asset { __typename id } caption url } ... on RichTextVideo { altText asset { __typename id } caption url } ... on RichTextOembed { authorName authorUrl height html iframeUrl originalUrl photoUrl providerName providerUrl thumbnailHeight thumbnailUrl thumbnailWidth title type version width } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.RichTextItem }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsRichText.self),
    .inlineFragment(AsRichTextHeader.self),
    .inlineFragment(AsRichTextListItem.self),
    .inlineFragment(AsRichTextListOpen.self),
    .inlineFragment(AsRichTextListClose.self),
    .inlineFragment(AsRichTextPhoto.self),
    .inlineFragment(AsRichTextAudio.self),
    .inlineFragment(AsRichTextVideo.self),
    .inlineFragment(AsRichTextOembed.self),
  ] }

  public var asRichText: AsRichText? { _asInlineFragment() }
  public var asRichTextHeader: AsRichTextHeader? { _asInlineFragment() }
  public var asRichTextListItem: AsRichTextListItem? { _asInlineFragment() }
  public var asRichTextListOpen: AsRichTextListOpen? { _asInlineFragment() }
  public var asRichTextListClose: AsRichTextListClose? { _asInlineFragment() }
  public var asRichTextPhoto: AsRichTextPhoto? { _asInlineFragment() }
  public var asRichTextAudio: AsRichTextAudio? { _asInlineFragment() }
  public var asRichTextVideo: AsRichTextVideo? { _asInlineFragment() }
  public var asRichTextOembed: AsRichTextOembed? { _asInlineFragment() }

  public init(
    __typename: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
      ],
      fulfilledFragments: [
        ObjectIdentifier(RichTextItemFragment.self)
      ]
    ))
  }

  /// AsRichText
  ///
  /// Parent Type: `RichText`
  public struct AsRichText: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichText }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("text", String?.self),
      .field("link", String?.self),
      .field("styles", [String]?.self),
    ] }

    public var text: String? { __data["text"] }
    public var link: String? { __data["link"] }
    public var styles: [String]? { __data["styles"] }

    public init(
      text: String? = nil,
      link: String? = nil,
      styles: [String]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichText.typename,
          "text": text,
          "link": link,
          "styles": styles,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichText.self)
        ]
      ))
    }
  }

  /// AsRichTextHeader
  ///
  /// Parent Type: `RichTextHeader`
  public struct AsRichTextHeader: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextHeader }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("text", String?.self),
      .field("link", String?.self),
      .field("styles", [String]?.self),
    ] }

    public var text: String? { __data["text"] }
    public var link: String? { __data["link"] }
    public var styles: [String]? { __data["styles"] }

    public init(
      text: String? = nil,
      link: String? = nil,
      styles: [String]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextHeader.typename,
          "text": text,
          "link": link,
          "styles": styles,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextHeader.self)
        ]
      ))
    }
  }

  /// AsRichTextListItem
  ///
  /// Parent Type: `RichTextListItem`
  public struct AsRichTextListItem: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListItem }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("text", String?.self),
      .field("link", String?.self),
      .field("styles", [String]?.self),
    ] }

    public var text: String? { __data["text"] }
    public var link: String? { __data["link"] }
    public var styles: [String]? { __data["styles"] }

    public init(
      text: String? = nil,
      link: String? = nil,
      styles: [String]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextListItem.typename,
          "text": text,
          "link": link,
          "styles": styles,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextListItem.self)
        ]
      ))
    }
  }

  /// AsRichTextListOpen
  ///
  /// Parent Type: `RichTextListOpen`
  public struct AsRichTextListOpen: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListOpen }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("_present", Bool.self),
    ] }

    /// Placeholder to avoid empty type
    public var _present: Bool { __data["_present"] }

    public init(
      _present: Bool
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextListOpen.typename,
          "_present": _present,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextListOpen.self)
        ]
      ))
    }
  }

  /// AsRichTextListClose
  ///
  /// Parent Type: `RichTextListClose`
  public struct AsRichTextListClose: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListClose }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("_present", Bool.self),
    ] }

    /// Placeholder to avoid empty type
    public var _present: Bool { __data["_present"] }

    public init(
      _present: Bool
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextListClose.typename,
          "_present": _present,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextListClose.self)
        ]
      ))
    }
  }

  /// AsRichTextPhoto
  ///
  /// Parent Type: `RichTextPhoto`
  public struct AsRichTextPhoto: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextPhoto }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("altText", String.self),
      .field("asset", Asset?.self),
      .field("caption", String.self),
      .field("url", String.self),
    ] }

    public var altText: String { __data["altText"] }
    public var asset: Asset? { __data["asset"] }
    public var caption: String { __data["caption"] }
    public var url: String { __data["url"] }

    public init(
      altText: String,
      asset: Asset? = nil,
      caption: String,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextPhoto.typename,
          "altText": altText,
          "asset": asset._fieldData,
          "caption": caption,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextPhoto.self)
        ]
      ))
    }

    /// AsRichTextPhoto.Asset
    ///
    /// Parent Type: `Photo`
    public struct Asset: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Photo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }

      public init(
        id: GraphAPI.ID
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.Photo.typename,
            "id": id,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextItemFragment.AsRichTextPhoto.Asset.self)
          ]
        ))
      }
    }
  }

  /// AsRichTextAudio
  ///
  /// Parent Type: `RichTextAudio`
  public struct AsRichTextAudio: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextAudio }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("altText", String.self),
      .field("asset", Asset?.self),
      .field("caption", String.self),
      .field("url", String.self),
    ] }

    public var altText: String { __data["altText"] }
    public var asset: Asset? { __data["asset"] }
    public var caption: String { __data["caption"] }
    public var url: String { __data["url"] }

    public init(
      altText: String,
      asset: Asset? = nil,
      caption: String,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextAudio.typename,
          "altText": altText,
          "asset": asset._fieldData,
          "caption": caption,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextAudio.self)
        ]
      ))
    }

    /// AsRichTextAudio.Asset
    ///
    /// Parent Type: `AttachedAudio`
    public struct Asset: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.AttachedAudio }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }

      public init(
        id: GraphAPI.ID
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.AttachedAudio.typename,
            "id": id,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextItemFragment.AsRichTextAudio.Asset.self)
          ]
        ))
      }
    }
  }

  /// AsRichTextVideo
  ///
  /// Parent Type: `RichTextVideo`
  public struct AsRichTextVideo: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextVideo }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("altText", String.self),
      .field("asset", Asset?.self),
      .field("caption", String.self),
      .field("url", String.self),
    ] }

    public var altText: String { __data["altText"] }
    public var asset: Asset? { __data["asset"] }
    public var caption: String { __data["caption"] }
    public var url: String { __data["url"] }

    public init(
      altText: String,
      asset: Asset? = nil,
      caption: String,
      url: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextVideo.typename,
          "altText": altText,
          "asset": asset._fieldData,
          "caption": caption,
          "url": url,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextVideo.self)
        ]
      ))
    }

    /// AsRichTextVideo.Asset
    ///
    /// Parent Type: `AttachedVideo`
    public struct Asset: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.AttachedVideo }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", GraphAPI.ID.self),
      ] }

      public var id: GraphAPI.ID { __data["id"] }

      public init(
        id: GraphAPI.ID
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.AttachedVideo.typename,
            "id": id,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextItemFragment.AsRichTextVideo.Asset.self)
          ]
        ))
      }
    }
  }

  /// AsRichTextOembed
  ///
  /// Parent Type: `RichTextOembed`
  public struct AsRichTextOembed: GraphAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = RichTextItemFragment
    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextOembed }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("authorName", String.self),
      .field("authorUrl", String.self),
      .field("height", Int.self),
      .field("html", String.self),
      .field("iframeUrl", String.self),
      .field("originalUrl", String.self),
      .field("photoUrl", String.self),
      .field("providerName", String.self),
      .field("providerUrl", String.self),
      .field("thumbnailHeight", Int.self),
      .field("thumbnailUrl", String.self),
      .field("thumbnailWidth", Int.self),
      .field("title", String.self),
      .field("type", String.self),
      .field("version", String.self),
      .field("width", Int.self),
    ] }

    /// ex: Bryson Lovett
    public var authorName: String { __data["authorName"] }
    /// ex: https://www.youtube.com/user/brysonlovett
    public var authorUrl: String { __data["authorUrl"] }
    /// ex: 270
    public var height: Int { __data["height"] }
    /// ex: <iframe width="560" height="315" src="https://www.youtube.com/embed/ijeaVn8znJ8?feature=oembed" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    public var html: String { __data["html"] }
    /// ex: https://www.youtube.com/embed/ijeaVn8znJ8?feature=oembed
    public var iframeUrl: String { __data["iframeUrl"] }
    /// ex: https://youtu.be/ijeaVn8znJ8
    public var originalUrl: String { __data["originalUrl"] }
    /// only for photo
    public var photoUrl: String { __data["photoUrl"] }
    /// Ex: Embedly, Flickr, Kickstarter, Kickstarter Live, Scribd, SoundCloud, Spotify, Sketchfab, Twitter, Vimeo, YouTube
    public var providerName: String { __data["providerName"] }
    /// ex: https://www.youtube.com/
    public var providerUrl: String { __data["providerUrl"] }
    /// ex: 360
    public var thumbnailHeight: Int { __data["thumbnailHeight"] }
    /// ex: https://i.ytimg.com/vi/ijeaVn8znJ8/hqdefault.jpg
    public var thumbnailUrl: String { __data["thumbnailUrl"] }
    /// ex: 480
    public var thumbnailWidth: Int { __data["thumbnailWidth"] }
    /// ex: Bird Photo Booth bird feeder kickstarter preview 2
    public var title: String { __data["title"] }
    /// one of: photo, video, link, rich
    public var type: String { __data["type"] }
    /// always "1.0"
    public var version: String { __data["version"] }
    /// ex: 480
    public var width: Int { __data["width"] }

    public init(
      authorName: String,
      authorUrl: String,
      height: Int,
      html: String,
      iframeUrl: String,
      originalUrl: String,
      photoUrl: String,
      providerName: String,
      providerUrl: String,
      thumbnailHeight: Int,
      thumbnailUrl: String,
      thumbnailWidth: Int,
      title: String,
      type: String,
      version: String,
      width: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.RichTextOembed.typename,
          "authorName": authorName,
          "authorUrl": authorUrl,
          "height": height,
          "html": html,
          "iframeUrl": iframeUrl,
          "originalUrl": originalUrl,
          "photoUrl": photoUrl,
          "providerName": providerName,
          "providerUrl": providerUrl,
          "thumbnailHeight": thumbnailHeight,
          "thumbnailUrl": thumbnailUrl,
          "thumbnailWidth": thumbnailWidth,
          "title": title,
          "type": type,
          "version": version,
          "width": width,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextItemFragment.self),
          ObjectIdentifier(RichTextItemFragment.AsRichTextOembed.self)
        ]
      ))
    }
  }
}
