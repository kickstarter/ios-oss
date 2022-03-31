import SwiftSoup

enum ViewElementType: String {
  case audio
  case imageAudioOrVideo
  case text
  case video
  case externalSources = "iframe"

  init?(element: Element) {
    let tagName = element.tag().getName()

    switch tagName {
    case HTMLRawText.Base.div.rawValue:
      guard let childElementType = element.extractViewElementTypeFromDiv() else {
        return nil
      }

      self = childElementType
    case TextComponent.TextBlockType.header1.rawValue,
         TextComponent.TextBlockType.unorderedList.rawValue,
         TextComponent.TextBlockType.orderedList.rawValue,
         TextComponent.TextBlockType.paragraph.rawValue:
      self = .text
    case ViewElementType.video.rawValue:
      self = .video
    case ViewElementType.audio.rawValue:
      self = .audio
    default:
      return nil
    }
  }
}
