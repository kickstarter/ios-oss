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
    let styles: [String]
    let children: [RichTextElement]
  }

  public enum HeaderLevel {
    case one
    case two
    case three
    case four
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
    let photoUrl: String?

    let thumbnailUrl: String?
    let thumbnailWidth: Int?
    let thumbnailHeight: Int?
  }
}
