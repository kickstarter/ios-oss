import Foundation

/// Represents a single block-level element in a RichText list. Used to make implementing
/// the different views in SwiftUI more easily and with a consistent interface.
public indirect enum RichTextElement {
  case text(Text, HeaderLevel?)
  case listItemOpen
  case listItemClose
  case listItem(Text)
  case audio(Audio)
  case photo(Photo)
  case video(Video)
  case oembed(Oembed)
  case unknown

  public struct Text {
    public let text: String
    public let link: URL?
    public let styles: [Style]
    public let children: [RichTextElement]

    public enum Style: String {
      case strong = "STRONG"
      case emphasis = "EMPHASIS"
      case heading1 = "HEADING_1"
      case heading2 = "HEADING_2"
      case heading3 = "HEADING_3"
      case heading4 = "HEADING_4"
    }
  }

  public enum HeaderLevel: String {
    case one = "HEADING_1"
    case two = "HEADING_2"
    case three = "HEADING_3"
    case four = "HEADING_4"

    /// Create a HeaderLevel from an array of style strings from GraphQL, if
    /// one is present
    internal init?(styles: [String]?) {
      for style in styles ?? [] {
        if let level = HeaderLevel(rawValue: style) {
          self = level
          return
        }
      }
      return nil
    }
  }

  public struct Audio {
    public let altText: String?
    public let assetID: String?
    public let caption: String?
    public let url: String?
  }

  public struct Photo {
    public let altText: String?
    public let assetID: String?
    public let caption: String?
    public let url: String?
  }

  public struct Video {
    public let altText: String?
    public let assetID: String?
    public let caption: String?
    public let url: String?
  }

  public struct Oembed {
    public let width: Int
    public let height: Int
    public let version: String
    public let title: String
    public let type: String

    public let iframeUrl: String?
    public let originalUrl: String?

    public let thumbnailUrl: String?
    public let thumbnailWidth: Int?
    public let thumbnailHeight: Int?
  }
}
