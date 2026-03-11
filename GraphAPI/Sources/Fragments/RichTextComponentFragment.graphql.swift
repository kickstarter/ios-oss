// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct RichTextComponentFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment RichTextComponentFragment on RichTextComponent { __typename items { __typename ...RichTextItemFragment ... on RichText { children { __typename ...RichTextItemFragment } } ... on RichTextHeader { children { __typename ...RichTextItemFragment } } ... on RichTextListItem { children { __typename ...RichTextItemFragment } } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextComponent }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("items", [Item].self),
  ] }

  public var items: [Item] { __data["items"] }

  public init(
    items: [Item]
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.RichTextComponent.typename,
        "items": items._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(RichTextComponentFragment.self)
      ]
    ))
  }

  /// Item
  ///
  /// Parent Type: `RichTextItem`
  public struct Item: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.RichTextItem }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsRichText.self),
      .inlineFragment(AsRichTextHeader.self),
      .inlineFragment(AsRichTextListItem.self),
      .fragment(RichTextItemFragment.self),
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

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var richTextItemFragment: RichTextItemFragment { _toFragment() }
    }

    public init(
      __typename: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": __typename,
        ],
        fulfilledFragments: [
          ObjectIdentifier(RichTextComponentFragment.Item.self)
        ]
      ))
    }

    /// Item.AsRichText
    ///
    /// Parent Type: `RichText`
    public struct AsRichText: GraphAPI.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichText }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("children", [Child]?.self),
      ] }

      public var children: [Child]? { __data["children"] }
      public var text: String? { __data["text"] }
      public var link: String? { __data["link"] }
      public var styles: [String]? { __data["styles"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

      public init(
        children: [Child]? = nil,
        text: String? = nil,
        link: String? = nil,
        styles: [String]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RichText.typename,
            "children": children._fieldData,
            "text": text,
            "link": link,
            "styles": styles,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichText.self)
          ]
        ))
      }

      /// Item.AsRichText.Child
      ///
      /// Parent Type: `RichTextItem`
      public struct Child: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.RichTextItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RichTextItemFragment.self),
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

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var richTextItemFragment: RichTextItemFragment { _toFragment() }
        }

        public init(
          __typename: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self)
            ]
          ))
        }

        /// Item.AsRichText.Child.AsRichText
        ///
        /// Parent Type: `RichText`
        public struct AsRichText: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichText }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichText.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichText.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichText.self)
              ]
            ))
          }
        }

        /// Item.AsRichText.Child.AsRichTextHeader
        ///
        /// Parent Type: `RichTextHeader`
        public struct AsRichTextHeader: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextHeader }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextHeader.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextHeader.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextHeader.self)
              ]
            ))
          }
        }

        /// Item.AsRichText.Child.AsRichTextListItem
        ///
        /// Parent Type: `RichTextListItem`
        public struct AsRichTextListItem: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListItem }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListItem.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListItem.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListItem.self)
              ]
            ))
          }
        }

        /// Item.AsRichText.Child.AsRichTextListOpen
        ///
        /// Parent Type: `RichTextListOpen`
        public struct AsRichTextListOpen: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListOpen }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListOpen.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          /// Placeholder to avoid empty type
          public var _present: Bool { __data["_present"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            _present: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextListOpen.typename,
                "_present": _present,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListOpen.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListOpen.self)
              ]
            ))
          }
        }

        /// Item.AsRichText.Child.AsRichTextListClose
        ///
        /// Parent Type: `RichTextListClose`
        public struct AsRichTextListClose: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListClose }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListClose.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          /// Placeholder to avoid empty type
          public var _present: Bool { __data["_present"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            _present: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextListClose.typename,
                "_present": _present,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListClose.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListClose.self)
              ]
            ))
          }
        }

        /// Item.AsRichText.Child.AsRichTextPhoto
        ///
        /// Parent Type: `RichTextPhoto`
        public struct AsRichTextPhoto: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextPhoto }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextPhoto.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextPhoto.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextPhoto.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextPhoto.Asset
        }

        /// Item.AsRichText.Child.AsRichTextAudio
        ///
        /// Parent Type: `RichTextAudio`
        public struct AsRichTextAudio: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextAudio }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextAudio.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextAudio.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextAudio.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextAudio.Asset
        }

        /// Item.AsRichText.Child.AsRichTextVideo
        ///
        /// Parent Type: `RichTextVideo`
        public struct AsRichTextVideo: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextVideo }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextVideo.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextVideo.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextVideo.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextVideo.Asset
        }

        /// Item.AsRichText.Child.AsRichTextOembed
        ///
        /// Parent Type: `RichTextOembed`
        public struct AsRichTextOembed: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichText.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextOembed }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextOembed.self,
            RichTextComponentFragment.Item.AsRichText.Child.self
          ] }

          /// ex: 480
          public var width: Int { __data["width"] }
          /// ex: 270
          public var height: Int { __data["height"] }
          /// always "1.0"
          public var version: String { __data["version"] }
          /// ex: Bird Photo Booth bird feeder kickstarter preview 2
          public var title: String { __data["title"] }
          /// one of: photo, video, link, rich
          public var type: String { __data["type"] }
          /// ex: https://www.youtube.com/embed/ijeaVn8znJ8?feature=oembed
          public var iframeUrl: String { __data["iframeUrl"] }
          /// ex: https://youtu.be/ijeaVn8znJ8
          public var originalUrl: String { __data["originalUrl"] }
          /// ex: 360
          public var thumbnailHeight: Int { __data["thumbnailHeight"] }
          /// ex: https://i.ytimg.com/vi/ijeaVn8znJ8/hqdefault.jpg
          public var thumbnailUrl: String { __data["thumbnailUrl"] }
          /// ex: 480
          public var thumbnailWidth: Int { __data["thumbnailWidth"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            width: Int,
            height: Int,
            version: String,
            title: String,
            type: String,
            iframeUrl: String,
            originalUrl: String,
            thumbnailHeight: Int,
            thumbnailUrl: String,
            thumbnailWidth: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextOembed.typename,
                "width": width,
                "height": height,
                "version": version,
                "title": title,
                "type": type,
                "iframeUrl": iframeUrl,
                "originalUrl": originalUrl,
                "thumbnailHeight": thumbnailHeight,
                "thumbnailUrl": thumbnailUrl,
                "thumbnailWidth": thumbnailWidth,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichText.Child.AsRichTextOembed.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextOembed.self)
              ]
            ))
          }
        }
      }
    }

    /// Item.AsRichTextHeader
    ///
    /// Parent Type: `RichTextHeader`
    public struct AsRichTextHeader: GraphAPI.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextHeader }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("children", [Child]?.self),
      ] }

      public var children: [Child]? { __data["children"] }
      public var text: String? { __data["text"] }
      public var link: String? { __data["link"] }
      public var styles: [String]? { __data["styles"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

      public init(
        children: [Child]? = nil,
        text: String? = nil,
        link: String? = nil,
        styles: [String]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RichTextHeader.typename,
            "children": children._fieldData,
            "text": text,
            "link": link,
            "styles": styles,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextHeader.self)
          ]
        ))
      }

      /// Item.AsRichTextHeader.Child
      ///
      /// Parent Type: `RichTextItem`
      public struct Child: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.RichTextItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RichTextItemFragment.self),
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

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var richTextItemFragment: RichTextItemFragment { _toFragment() }
        }

        public init(
          __typename: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self)
            ]
          ))
        }

        /// Item.AsRichTextHeader.Child.AsRichText
        ///
        /// Parent Type: `RichText`
        public struct AsRichText: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichText }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichText.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichText.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichText.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextHeader.Child.AsRichTextHeader
        ///
        /// Parent Type: `RichTextHeader`
        public struct AsRichTextHeader: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextHeader }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextHeader.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextHeader.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextHeader.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextHeader.Child.AsRichTextListItem
        ///
        /// Parent Type: `RichTextListItem`
        public struct AsRichTextListItem: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListItem }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListItem.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListItem.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListItem.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextHeader.Child.AsRichTextListOpen
        ///
        /// Parent Type: `RichTextListOpen`
        public struct AsRichTextListOpen: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListOpen }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListOpen.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          /// Placeholder to avoid empty type
          public var _present: Bool { __data["_present"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            _present: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextListOpen.typename,
                "_present": _present,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListOpen.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListOpen.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextHeader.Child.AsRichTextListClose
        ///
        /// Parent Type: `RichTextListClose`
        public struct AsRichTextListClose: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListClose }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListClose.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          /// Placeholder to avoid empty type
          public var _present: Bool { __data["_present"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            _present: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextListClose.typename,
                "_present": _present,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListClose.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListClose.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextHeader.Child.AsRichTextPhoto
        ///
        /// Parent Type: `RichTextPhoto`
        public struct AsRichTextPhoto: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextPhoto }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextPhoto.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextPhoto.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextPhoto.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextPhoto.Asset
        }

        /// Item.AsRichTextHeader.Child.AsRichTextAudio
        ///
        /// Parent Type: `RichTextAudio`
        public struct AsRichTextAudio: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextAudio }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextAudio.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextAudio.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextAudio.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextAudio.Asset
        }

        /// Item.AsRichTextHeader.Child.AsRichTextVideo
        ///
        /// Parent Type: `RichTextVideo`
        public struct AsRichTextVideo: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextVideo }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextVideo.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextVideo.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextVideo.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextVideo.Asset
        }

        /// Item.AsRichTextHeader.Child.AsRichTextOembed
        ///
        /// Parent Type: `RichTextOembed`
        public struct AsRichTextOembed: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextHeader.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextOembed }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextOembed.self,
            RichTextComponentFragment.Item.AsRichTextHeader.Child.self
          ] }

          /// ex: 480
          public var width: Int { __data["width"] }
          /// ex: 270
          public var height: Int { __data["height"] }
          /// always "1.0"
          public var version: String { __data["version"] }
          /// ex: Bird Photo Booth bird feeder kickstarter preview 2
          public var title: String { __data["title"] }
          /// one of: photo, video, link, rich
          public var type: String { __data["type"] }
          /// ex: https://www.youtube.com/embed/ijeaVn8znJ8?feature=oembed
          public var iframeUrl: String { __data["iframeUrl"] }
          /// ex: https://youtu.be/ijeaVn8znJ8
          public var originalUrl: String { __data["originalUrl"] }
          /// ex: 360
          public var thumbnailHeight: Int { __data["thumbnailHeight"] }
          /// ex: https://i.ytimg.com/vi/ijeaVn8znJ8/hqdefault.jpg
          public var thumbnailUrl: String { __data["thumbnailUrl"] }
          /// ex: 480
          public var thumbnailWidth: Int { __data["thumbnailWidth"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            width: Int,
            height: Int,
            version: String,
            title: String,
            type: String,
            iframeUrl: String,
            originalUrl: String,
            thumbnailHeight: Int,
            thumbnailUrl: String,
            thumbnailWidth: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextOembed.typename,
                "width": width,
                "height": height,
                "version": version,
                "title": title,
                "type": type,
                "iframeUrl": iframeUrl,
                "originalUrl": originalUrl,
                "thumbnailHeight": thumbnailHeight,
                "thumbnailUrl": thumbnailUrl,
                "thumbnailWidth": thumbnailWidth,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextOembed.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextOembed.self)
              ]
            ))
          }
        }
      }
    }

    /// Item.AsRichTextListItem
    ///
    /// Parent Type: `RichTextListItem`
    public struct AsRichTextListItem: GraphAPI.InlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListItem }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("children", [Child]?.self),
      ] }

      public var children: [Child]? { __data["children"] }
      public var text: String? { __data["text"] }
      public var link: String? { __data["link"] }
      public var styles: [String]? { __data["styles"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

      public init(
        children: [Child]? = nil,
        text: String? = nil,
        link: String? = nil,
        styles: [String]? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RichTextListItem.typename,
            "children": children._fieldData,
            "text": text,
            "link": link,
            "styles": styles,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextListItem.self)
          ]
        ))
      }

      /// Item.AsRichTextListItem.Child
      ///
      /// Parent Type: `RichTextItem`
      public struct Child: GraphAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GraphAPI.Unions.RichTextItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(RichTextItemFragment.self),
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

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var richTextItemFragment: RichTextItemFragment { _toFragment() }
        }

        public init(
          __typename: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
            ],
            fulfilledFragments: [
              ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self)
            ]
          ))
        }

        /// Item.AsRichTextListItem.Child.AsRichText
        ///
        /// Parent Type: `RichText`
        public struct AsRichText: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichText }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichText.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichText.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichText.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextListItem.Child.AsRichTextHeader
        ///
        /// Parent Type: `RichTextHeader`
        public struct AsRichTextHeader: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextHeader }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextHeader.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextHeader.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextHeader.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextListItem.Child.AsRichTextListItem
        ///
        /// Parent Type: `RichTextListItem`
        public struct AsRichTextListItem: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListItem }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListItem.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          public var text: String? { __data["text"] }
          public var link: String? { __data["link"] }
          public var styles: [String]? { __data["styles"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListItem.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListItem.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextListItem.Child.AsRichTextListOpen
        ///
        /// Parent Type: `RichTextListOpen`
        public struct AsRichTextListOpen: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListOpen }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListOpen.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          /// Placeholder to avoid empty type
          public var _present: Bool { __data["_present"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            _present: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextListOpen.typename,
                "_present": _present,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListOpen.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListOpen.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextListItem.Child.AsRichTextListClose
        ///
        /// Parent Type: `RichTextListClose`
        public struct AsRichTextListClose: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListClose }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextListClose.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          /// Placeholder to avoid empty type
          public var _present: Bool { __data["_present"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            _present: Bool
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextListClose.typename,
                "_present": _present,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListClose.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextListClose.self)
              ]
            ))
          }
        }

        /// Item.AsRichTextListItem.Child.AsRichTextPhoto
        ///
        /// Parent Type: `RichTextPhoto`
        public struct AsRichTextPhoto: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextPhoto }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextPhoto.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextPhoto.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextPhoto.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextPhoto.Asset
        }

        /// Item.AsRichTextListItem.Child.AsRichTextAudio
        ///
        /// Parent Type: `RichTextAudio`
        public struct AsRichTextAudio: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextAudio }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextAudio.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextAudio.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextAudio.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextAudio.Asset
        }

        /// Item.AsRichTextListItem.Child.AsRichTextVideo
        ///
        /// Parent Type: `RichTextVideo`
        public struct AsRichTextVideo: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextVideo }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextVideo.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          public var altText: String { __data["altText"] }
          public var asset: Asset? { __data["asset"] }
          public var caption: String { __data["caption"] }
          public var url: String { __data["url"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

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
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextVideo.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextVideo.self)
              ]
            ))
          }

          public typealias Asset = RichTextItemFragment.AsRichTextVideo.Asset
        }

        /// Item.AsRichTextListItem.Child.AsRichTextOembed
        ///
        /// Parent Type: `RichTextOembed`
        public struct AsRichTextOembed: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = RichTextComponentFragment.Item.AsRichTextListItem.Child
          public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextOembed }
          public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
            RichTextItemFragment.AsRichTextOembed.self,
            RichTextComponentFragment.Item.AsRichTextListItem.Child.self
          ] }

          /// ex: 480
          public var width: Int { __data["width"] }
          /// ex: 270
          public var height: Int { __data["height"] }
          /// always "1.0"
          public var version: String { __data["version"] }
          /// ex: Bird Photo Booth bird feeder kickstarter preview 2
          public var title: String { __data["title"] }
          /// one of: photo, video, link, rich
          public var type: String { __data["type"] }
          /// ex: https://www.youtube.com/embed/ijeaVn8znJ8?feature=oembed
          public var iframeUrl: String { __data["iframeUrl"] }
          /// ex: https://youtu.be/ijeaVn8znJ8
          public var originalUrl: String { __data["originalUrl"] }
          /// ex: 360
          public var thumbnailHeight: Int { __data["thumbnailHeight"] }
          /// ex: https://i.ytimg.com/vi/ijeaVn8znJ8/hqdefault.jpg
          public var thumbnailUrl: String { __data["thumbnailUrl"] }
          /// ex: 480
          public var thumbnailWidth: Int { __data["thumbnailWidth"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var richTextItemFragment: RichTextItemFragment { _toFragment() }
          }

          public init(
            width: Int,
            height: Int,
            version: String,
            title: String,
            type: String,
            iframeUrl: String,
            originalUrl: String,
            thumbnailHeight: Int,
            thumbnailUrl: String,
            thumbnailWidth: Int
          ) {
            self.init(_dataDict: DataDict(
              data: [
                "__typename": GraphAPI.Objects.RichTextOembed.typename,
                "width": width,
                "height": height,
                "version": version,
                "title": title,
                "type": type,
                "iframeUrl": iframeUrl,
                "originalUrl": originalUrl,
                "thumbnailHeight": thumbnailHeight,
                "thumbnailUrl": thumbnailUrl,
                "thumbnailWidth": thumbnailWidth,
              ],
              fulfilledFragments: [
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.self),
                ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextOembed.self),
                ObjectIdentifier(RichTextItemFragment.self),
                ObjectIdentifier(RichTextItemFragment.AsRichTextOembed.self)
              ]
            ))
          }
        }
      }
    }

    /// Item.AsRichTextListOpen
    ///
    /// Parent Type: `RichTextListOpen`
    public struct AsRichTextListOpen: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListOpen }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RichTextComponentFragment.Item.self,
        RichTextItemFragment.AsRichTextListOpen.self
      ] }

      /// Placeholder to avoid empty type
      public var _present: Bool { __data["_present"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

      public init(
        _present: Bool
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RichTextListOpen.typename,
            "_present": _present,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListOpen.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextListOpen.self)
          ]
        ))
      }
    }

    /// Item.AsRichTextListClose
    ///
    /// Parent Type: `RichTextListClose`
    public struct AsRichTextListClose: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextListClose }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RichTextComponentFragment.Item.self,
        RichTextItemFragment.AsRichTextListClose.self
      ] }

      /// Placeholder to avoid empty type
      public var _present: Bool { __data["_present"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

      public init(
        _present: Bool
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RichTextListClose.typename,
            "_present": _present,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextListClose.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextListClose.self)
          ]
        ))
      }
    }

    /// Item.AsRichTextPhoto
    ///
    /// Parent Type: `RichTextPhoto`
    public struct AsRichTextPhoto: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextPhoto }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RichTextComponentFragment.Item.self,
        RichTextItemFragment.AsRichTextPhoto.self
      ] }

      public var altText: String { __data["altText"] }
      public var asset: Asset? { __data["asset"] }
      public var caption: String { __data["caption"] }
      public var url: String { __data["url"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

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
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextPhoto.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextPhoto.self)
          ]
        ))
      }

      public typealias Asset = RichTextItemFragment.AsRichTextPhoto.Asset
    }

    /// Item.AsRichTextAudio
    ///
    /// Parent Type: `RichTextAudio`
    public struct AsRichTextAudio: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextAudio }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RichTextComponentFragment.Item.self,
        RichTextItemFragment.AsRichTextAudio.self
      ] }

      public var altText: String { __data["altText"] }
      public var asset: Asset? { __data["asset"] }
      public var caption: String { __data["caption"] }
      public var url: String { __data["url"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

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
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextAudio.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextAudio.self)
          ]
        ))
      }

      public typealias Asset = RichTextItemFragment.AsRichTextAudio.Asset
    }

    /// Item.AsRichTextVideo
    ///
    /// Parent Type: `RichTextVideo`
    public struct AsRichTextVideo: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextVideo }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RichTextComponentFragment.Item.self,
        RichTextItemFragment.AsRichTextVideo.self
      ] }

      public var altText: String { __data["altText"] }
      public var asset: Asset? { __data["asset"] }
      public var caption: String { __data["caption"] }
      public var url: String { __data["url"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

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
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextVideo.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextVideo.self)
          ]
        ))
      }

      public typealias Asset = RichTextItemFragment.AsRichTextVideo.Asset
    }

    /// Item.AsRichTextOembed
    ///
    /// Parent Type: `RichTextOembed`
    public struct AsRichTextOembed: GraphAPI.InlineFragment, ApolloAPI.CompositeInlineFragment {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = RichTextComponentFragment.Item
      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.RichTextOembed }
      public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
        RichTextComponentFragment.Item.self,
        RichTextItemFragment.AsRichTextOembed.self
      ] }

      /// ex: 480
      public var width: Int { __data["width"] }
      /// ex: 270
      public var height: Int { __data["height"] }
      /// always "1.0"
      public var version: String { __data["version"] }
      /// ex: Bird Photo Booth bird feeder kickstarter preview 2
      public var title: String { __data["title"] }
      /// one of: photo, video, link, rich
      public var type: String { __data["type"] }
      /// ex: https://www.youtube.com/embed/ijeaVn8znJ8?feature=oembed
      public var iframeUrl: String { __data["iframeUrl"] }
      /// ex: https://youtu.be/ijeaVn8znJ8
      public var originalUrl: String { __data["originalUrl"] }
      /// ex: 360
      public var thumbnailHeight: Int { __data["thumbnailHeight"] }
      /// ex: https://i.ytimg.com/vi/ijeaVn8znJ8/hqdefault.jpg
      public var thumbnailUrl: String { __data["thumbnailUrl"] }
      /// ex: 480
      public var thumbnailWidth: Int { __data["thumbnailWidth"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var richTextItemFragment: RichTextItemFragment { _toFragment() }
      }

      public init(
        width: Int,
        height: Int,
        version: String,
        title: String,
        type: String,
        iframeUrl: String,
        originalUrl: String,
        thumbnailHeight: Int,
        thumbnailUrl: String,
        thumbnailWidth: Int
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.RichTextOembed.typename,
            "width": width,
            "height": height,
            "version": version,
            "title": title,
            "type": type,
            "iframeUrl": iframeUrl,
            "originalUrl": originalUrl,
            "thumbnailHeight": thumbnailHeight,
            "thumbnailUrl": thumbnailUrl,
            "thumbnailWidth": thumbnailWidth,
          ],
          fulfilledFragments: [
            ObjectIdentifier(RichTextComponentFragment.Item.self),
            ObjectIdentifier(RichTextComponentFragment.Item.AsRichTextOembed.self),
            ObjectIdentifier(RichTextItemFragment.self),
            ObjectIdentifier(RichTextItemFragment.AsRichTextOembed.self)
          ]
        ))
      }
    }
  }
}
