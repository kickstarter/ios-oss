import Foundation
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

    children?.forEach { element in
      let viewElementType = ViewElementType.image // ViewElementType.initialize(element: element)

      switch viewElementType {
      case .image:
        // Remove this check to allow images on videos
        if let sourceUrl = element.dataset()["src"] {
          viewElements.append(ImageViewElement(src: sourceUrl))
        }
      case .text:
        viewElements.append(TextViewElement(components: parseTextElement(element: element)))
        return
      case .video:
        let sourceUrls = element.children().compactMap { try? $0.attr("src") }
        let videoViewElement = VideoViewElement(sourceUrls: sourceUrls)
        viewElements.append(videoViewElement)
      case .embeddedLink:
        let caption = try? element.getElementsByTag("figcaption").first()?.text()

        if let href = element.getAttributes()?.first(where: { $0.getKey() == "href" }),
          let imageElements = try? element.getElementsByTag("img") {
          for imageElement in imageElements {
            if let sourceUrl = imageElement.dataset()["src"] {
              viewElements
                .append(EmbeddedLinkViewElement(href: href.getValue(), src: sourceUrl, caption: caption))
            }
          }
        }
        return
      case .oembed:
        guard let attributes = element.getAttributes() else { break }
        let sourceUrls = attributes.compactMap { $0.getKey() == "data-href" ? $0.getValue() : nil }
        let videoViewElement = VideoViewElement(sourceUrls: sourceUrls)
        viewElements.append(videoViewElement)
      case .unknown:
//                viewElements.append(UnknownViewElement(text: "tag: \(element.tag().getName()) \(element.dataset().description)"))
        break
      }

      viewElements.append(contentsOf: parse(element.children()))
    }

    return viewElements
  }

  private func parseTextElement(element: Element, tags: [String] = [],
                                textComponents: [TextComponent] = []) -> [TextComponent] {
    let elementTags = tags + [element.tag().getName()]
    var components = textComponents

    for node in element.getChildNodes() {
      if let textNode = node as? TextNode {
        let href = element.getAttributes()?.first(where: { $0.getKey() == "href" })?.getValue()
        components.append(TextComponent(
          text: textNode.text(),
          link: href,
          styles: elementTags.map { TextStyleType.initalize(tag: $0) }
        ))
      } else if let nodeElement = node as? Element {
        components.append(contentsOf: self.parseTextElement(
          element: nodeElement,
          tags: elementTags,
          textComponents: components
        ))
      }
    }
    return components
  }
}
