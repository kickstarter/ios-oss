import SwiftSoup

public protocol HTMLViewElement {}

class HTMLParser {
  func parse(bodyHtml: String) -> [HTMLViewElement] {
    do {
      let doc: Document = try SwiftSoup.parseBodyFragment(bodyHtml)

      var viewElements = [HTMLViewElement]()

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
                     viewElements: inout [HTMLViewElement]) {
    let viewElementType = ViewElementType(element: child)
    var element: HTMLViewElement?

    switch viewElementType {
    case .imageAudioOrVideo:
      if let imageElement = child.parseImageElement() {
        element = imageElement
      } else if let childrenWithVideoTag = try? child.getElementsByTag(HTMLRawText.Base.video.rawValue),
        let childWithVideoTag = childrenWithVideoTag.first {
        element = self.createVideoElement(childWithVideoTag)
      } else if let childrenWithAudioTag = try? child.getElementsByTag(HTMLRawText.Base.audio.rawValue),
        let childWithAudioTag = childrenWithAudioTag.first {
        element = self.createAudioElement(childWithAudioTag)
      }
    case .text:
      var textComponents = [TextComponent]()

      parseTextElement(element: child, textComponents: &textComponents)

      let textViewElement = TextViewElement(components: textComponents)
      element = textViewElement
    case .video:
      element = self.createVideoElement(child)
    case .audio:
      element = self.createAudioElement(child)
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

  private func createAudioElement(_ child: Element) -> AudioVideoViewElement? {
    guard let sourceUrl = child.parseAudioElement() else {
      return nil
    }

    let thumbnailUrl = child.parseAudioVideoElementThumbnailUrl()
    let audioVideoViewElement = AudioVideoViewElement(
      sourceURLString: sourceUrl,
      thumbnailURLString: thumbnailUrl,
      seekPosition: .zero
    )

    return audioVideoViewElement
  }

  private func createVideoElement(_ child: Element) -> AudioVideoViewElement? {
    guard let sourceUrl = child.parseVideoElement() else {
      return nil
    }

    let thumbnailUrl = child.parseAudioVideoElementThumbnailUrl()
    let audioVideoViewElement = AudioVideoViewElement(
      sourceURLString: sourceUrl,
      thumbnailURLString: thumbnailUrl,
      seekPosition: .zero
    )

    return audioVideoViewElement
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
