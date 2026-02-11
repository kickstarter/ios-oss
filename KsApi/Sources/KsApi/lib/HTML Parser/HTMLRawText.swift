import Foundation

public enum HTMLRawText {
  enum Base: String {
    case htmlClass = "class"
    case height
    case iframe
    case div
    case video
    case audio
  }

  enum List: String {
    case listItem = "li"
    case unorderedList = "ul"
    case orderedList = "ol"
  }

  enum Link: String {
    case anchor = "a"
    case link = "href"
    case source = "src"
  }

  enum Image: String {
    case dataCaption = "data-caption"
    case dataSource = "data-src"
    case dataImage = "data-image"
    case gifExtension = ".gif"
  }

  enum Video: String {
    case high
  }

  enum KSRSpecific: String {
    case templateAsset = "template asset"
    case templateOembed = "template oembed"
  }
}
