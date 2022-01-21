import SwiftSoup

class HTMLParser {
  func parse(bodyHtml: String) -> [Decodable] {
    do {
      let doc: Document = try SwiftSoup.parseBodyFragment(bodyHtml)

      var viewElements = [Decodable]()

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
                     viewElements: inout [Decodable]) {
    let viewElementType = ViewElementType(element: child)
    var element: Decodable?

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
      switch node {
      case let textNode as TextNode:
        guard let textComponent = textNode.parseTextElement(element: element) else { continue }

        textComponents.append(textComponent)
      case let element as Element:
        var listStarted = false

        if TextComponent.TextStyleType(rawValue: element.tagName()) == .bulletStart {
          let listStartTextElement = TextComponent(text: "•  ", link: nil, styles: [.bulletStart])

          textComponents.append(listStartTextElement)

          listStarted = true
        }

        self.parseTextElement(element: element, textComponents: &textComponents)

        if listStarted {
          let listEndTextElement = TextComponent(text: "", link: nil, styles: [.bulletEnd])

          textComponents.append(listEndTextElement)
        }
      default:
        continue
      }
    }
  }
}
