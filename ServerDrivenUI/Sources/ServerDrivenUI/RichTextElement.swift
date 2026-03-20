import Foundation
import GraphAPI

public indirect enum RichTextElement {
  case text(Text, HeaderLevel?)
  case listItemOpen
  case listItemClose
  case listItem(Text)
  case audio(Audio)
  case photo(Photo)
  case video(Video)
  case oembed(Oembed)

  public struct Text {
    let text: String
    let link: URL?
    let styles: [Style]
    let children: [RichTextElement]

    public enum Style: String {
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

  public enum HeaderLevel: String {
    case one = "HEADING_1"
    case two = "HEADING_2"
    case three = "HEADING_3"
    case four = "HEADING_4"

    init?(_ rawValues: [String]?) {
      for rawValue in rawValues ?? [] {
        if let level = HeaderLevel(rawValue: rawValue) {
          self = level
          return
        }
      }
      return nil
    }
  }

  public struct Audio {
    let altText: String?
    let assetID: String?
    let caption: String?
    let url: String?
  }

  public struct Photo {
    let altText: String?
    let assetID: String?
    let caption: String?
    let url: String?
  }

  public struct Video {
    let altText: String?
    let assetID: String?
    let caption: String?
    let url: String?
  }

  public struct Oembed {
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
