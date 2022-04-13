import SwiftSoup

extension TextNode {
  /**
   * Each TextComponent will have:
   * - it's own list of styles to apply
   * - the url string in case the textComponent was a link
   * - the text to display
   */
  func parseTextElement(element: Element) -> TextComponent? {
    let text = text()

    var tagsOther = [String]()
    var urls = [String]()

    extractTextAttributes(element: element, tags: &tagsOther, urls: &urls)

    // - Extract from the list of styles `null` values and `LIST`, the list style is processed separately.
    let textStyleList = tagsOther.compactMap { TextComponent.TextStyleType(rawValue: $0) }
      .filter { $0 != .bulletStart }

    let href = urls.first ?? nil

    return TextComponent(text: text, link: href, styles: textStyleList)
  }

  // MARK: Helpers

  /**
   * This function extracts from the textNode a tag list from their ancestors
   * until it detects the parent blockType.
   *
   * Note: BlockTypes are direct children of body HTML tag
   * @param tags - Populates the list of parent tags
   * @param urls - In case of any of the parents is a link(<a>) populates the urls list
   */
  private func extractTextAttributes(element: Element,
                                     tags: inout [String],
                                     urls: inout [String]) {
    tags.append(element.tagName())

    if !TextComponent.TextBlockType.allCases.contains(where: { $0.rawValue == element.tagName() }) {
      if element.tagName() == HTMLRawText.Link.anchor.rawValue,
        let elementAttribute = try? element.attr(HTMLRawText.Link.link.rawValue) {
        urls.append(elementAttribute)
      }

      if let parent = element.parent() {
        self.extractTextAttributes(element: parent, tags: &tags, urls: &urls)
      }
    }
  }
}
