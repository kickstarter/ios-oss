import Foundation
import GraphAPI

/// Represents a single block-level element in a RichText list. Used to make implementing
/// the different views in SwiftUI more easily and with a consistent interface.
public indirect enum RichTextElement: Sendable {
  case text(Text, HeaderLevel?)
  case listItemOpen
  case listItemClose
  case listItem(Text)
  case audio(Audio)
  case photo(Photo)
  case video(Video)
  case oembed(Oembed)
  case unknown

  public struct Text: Sendable {
    let text: String
    let link: URL?
    let styles: [Style]
    let children: [RichTextElement]

    internal init(text: String, link: URL? = nil, styles: [Style] = [], children: [RichTextElement] = []) {
      self.text = text
      self.link = link
      self.styles = styles
      self.children = children
    }

    public enum Style: String, Sendable {
      case strong = "STRONG"
      case emphasis = "EMPHASIS"
      case heading1 = "HEADING_1"
      case heading2 = "HEADING_2"
      case heading3 = "HEADING_3"
      case heading4 = "HEADING_4"

      public init?(rawValue: String) {
        switch rawValue {
        case "STRONG":
          self = .strong
        case "EMPHASIS":
          self = .emphasis
        case "HEADING_1":
          self = .heading1
        case "HEADING_2":
          self = .heading2
        case "HEADING_3":
          self = .heading3
        case "HEADING_4":
          self = .heading4
        default:
          assertionFailure("unknown style type: \(rawValue)")
          return nil
        }
      }
    }
  }

  public enum HeaderLevel: String, Sendable {
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

  public struct Audio: Sendable {
    let altText: String?
    let assetID: String?
    let caption: String?
    let url: String?
  }

  public struct Photo: Sendable {
    let altText: String?
    let assetID: String?
    let caption: String?
    let url: String?
  }

  public struct Video: Sendable {
    let altText: String?
    let assetID: String?
    let caption: String?
    let url: String?
  }

  public struct Oembed: Sendable {
    let width: Int
    let height: Int
    let version: String
    let title: String
    let type: String

    let iframeUrl: String?
    let originalUrl: String?

    let thumbnailUrl: String?
    let thumbnailWidth: Int?
    let thumbnailHeight: Int?
  }
}
