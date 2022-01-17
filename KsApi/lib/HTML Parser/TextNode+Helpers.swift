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
    var textStyleList = tagsOther.compactMap { TextComponent.TextStyleType(rawValue: $0) }
      .filter { $0 != .list }

    let href = urls.first ?? nil

    // - I am child of a li, but not the element itself
    if tagsOther.contains(HTMLRawText.List.unorderedList.rawValue) {
      var list = [Element]()

      getListElements(element: element, listElements: &list)

      let listElement = list.first
      let parent = element.parent()
      let grandParent = parent?.parent()

      // - Clean up the liElement, many times you get empty child TextNodes or TextNodes with &nbsp
      let listChildElements = listElement?.getChildNodes().filter { node in
        if let textNode = node as? TextNode {
          return !textNode.text().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        return true
      }

      // Am I the first child of the LI element?
      if self == listChildElements?.first || element == listChildElements?.first {
        textStyleList.append(.list)
      } else {
        // Is my parent the first child of the LI element?
        if listChildElements?.first == parent {
          textStyleList.append(.list)
        }
      }

      // Am I the last child of the LI element?
      if self == listChildElements?.last || element == listChildElements?.last {
        textStyleList.append(.listEnd)
      } else {
        // Is my parent the first child of the LI element?
        if listChildElements?.last == parent {
          textStyleList.append(.listEnd)
        }
      }

      if textStyleList.count >= 3 {
        // Is my grand parent the first child of the LI element?
        if listChildElements?.first == grandParent {
          textStyleList.append(.list)
        }

        // Is my grand parent the last child of the LI element?
        if listChildElements?.last == grandParent {
          textStyleList.append(.listEnd)
        }
      }
    }

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

  private func getListElements(element: Element, listElements: inout [Element]) {
    if element.tagName().contains(HTMLRawText.List.listItem.rawValue) {
      listElements.append(element)
    } else if let parent = element.parent() {
      self.getListElements(element: parent, listElements: &listElements)
    }
  }
}
