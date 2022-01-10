import SwiftSoup

class HTMLParser {
  func parse(bodyHtml: String) -> [ViewElement] {
    do {
      let doc: Document = try SwiftSoup.parseBodyFragment(bodyHtml)

      var viewElements = [ViewElement]()

      doc.body()?.children().forEach { element in
        parse(element, viewElements: &viewElements)
      }

      return viewElements
    } catch {
      print("error parsing html")
    }
    return []
  }

  private func parse(_ child: Element,
                     viewElements: inout [ViewElement]) {
    let viewElementType = ViewElementType(element: child)
    var element: ViewElement?

    switch viewElementType {
    case .image:
      element = child.parseImageElement()
    case .text:
      var textComponents = [TextComponent]()

      parseTextElement(element: child, textComponents: &textComponents)

      let textViewElement = TextViewElement(components: textComponents)
      element = textViewElement
    case .video:
      guard let sourceUrl = child.parseVideoElement() else {
        element = nil

        return
      }

      let thumbnailUrl = child.parseVideoElementThumbnailUrl()
      let seekPosition: Int64 = 0
      let videoViewElement = VideoViewElement(
        sourceUrl: sourceUrl,
        thumbnailUrl: thumbnailUrl,
        seekPosition: seekPosition
      )

      element = videoViewElement
    case .externalSources:
      element = child.parseExternalElement()
    default:
      for child in child.children() {
        self.parse(child, viewElements: &viewElements)
      }
    }

    if let elementValue = element {
      viewElements.append(elementValue)
    }
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
