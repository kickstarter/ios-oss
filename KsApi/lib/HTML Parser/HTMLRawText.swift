import Foundation

public enum HTMLRawText {
  enum Base: String {
    case htmlClass = "class"
    case width
    case div
    case video
  }

  enum List: String {
    case listItem = "li"
    case unorderedList = "ul"
    case orderedList = "ol"
  }

  enum Size: String {
    case hundredPercent = "100%"
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
