import SwiftSoup

class HTMLParser {
  func parse(html: String) -> [ViewElement] {
    do {
      let doc: Document = try SwiftSoup.parse(html)

      var viewElements = [ViewElement]()

      doc.children().forEach { element in
        viewElements.append(contentsOf: parse(element.children()))
      }

      return viewElements
    } catch {
      print("error parsing html")
    }
    return []
  }

  private func parse(_ children: Elements?) -> [ViewElement] {
    var viewElements = [ViewElement]()

    guard let elements = children else {
      return viewElements
    }

    for element in elements {
      let viewElementType = ViewElementType(element: element)

      switch viewElementType {
      case .image:
        viewElements.append(element.parseImageElement())
      case .text:
        var textComponents = [TextComponent]()

        parseTextElement(element: element, textComponents: &textComponents)

        let textViewElement = TextViewElement(components: textComponents)

        viewElements.append(textViewElement)
      case .video:
        guard let sourceUrl = element.parseVideoElement() else {
          continue
        }

        let thumbnailUrl = element.parseVideoElementThumbnailUrl()
        let seekPosition: Int64 = 0
        let videoViewElement = VideoViewElement(
          sourceUrl: sourceUrl,
          thumbnailUrl: thumbnailUrl,
          seekPosition: seekPosition
        )

        viewElements.append(videoViewElement)
      case .externalSources:
        viewElements.append(element.parseExternalElement())
      default:
        let parsedRemainingChildren = self.parse(element.children())

        viewElements.append(contentsOf: parsedRemainingChildren)
      }
    }

    return viewElements
  }

  private func parseTextElement(element: Element,
                                textComponents: inout [TextComponent]) {
    for node in element.getChildNodes() {
      if let textNode = node as? TextNode,
        !textNode.text().trimmingCharacters(in: .whitespaces).isEmpty,
        let textComponent = textNode.parseTextElement(element: element) {
        textComponents.append(textComponent)
      } else if let element = node as? Element {
        self.parseTextElement(element: element, textComponents: &textComponents)
      }
    }
  }
}
