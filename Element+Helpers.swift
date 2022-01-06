import SwiftSoup

// INFO: Huge thank you to Android team for figuring out which HTML components are being returned by backend for `story` property. We just essentially just ported it all over to iOS.

extension Element {
  enum HTMLRawText {
    enum Base: String {
      case htmlClass = "class"
      case width
    }

    enum List: String {
      case listItem = "li"
      case unorderedList = "ul"
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

  func extractViewElementTypeFromDiv() -> ViewElementType {
    var type = ViewElementType.unknown

    let emptyChildren = children().isEmpty()
    let emptyChildrensChildren = !emptyChildren ? children()[0].children().isEmpty() : true

    if self.isImageStructure(),
      !emptyChildrensChildren,
      children()[0].children()[0].tag().getName() == ViewElementType.image.rawValue {
      type = .image
    } else if self.isIframeStructure(),
      !emptyChildrensChildren,
      children()[0].tag().getName() == ViewElementType.externalSources.rawValue {
      type = .externalSources
    }

    return type
  }

  func isIframeStructure() -> Bool {
    let templateDivAttributes = getAttributes()?.filter { attribute in
      let classKey = attribute.getKey() == HTMLRawText.Base.htmlClass.rawValue
      let templateOembedValue = attribute.getValue() == HTMLRawText.KSRSpecific.templateOembed.rawValue

      return classKey && templateOembedValue
    }

    if let templateDivAttributesValue = templateDivAttributes {
      return !templateDivAttributesValue.isEmpty
    }

    return false
  }

  func isImageStructure() -> Bool {
    let templateDivAttributes = getAttributes()?.filter { attribute in
      let classKey = attribute.getKey() == HTMLRawText.Base.htmlClass.rawValue
      let templateAssetValue = attribute.getValue() == HTMLRawText.KSRSpecific.templateAsset.rawValue

      return classKey && templateAssetValue
    }

    if let templateDivAttributesValue = templateDivAttributes {
      return !templateDivAttributesValue.isEmpty
    }

    return false
  }

  func parseVideoElement() -> String? {
    let sourceUrls = children().compactMap { try? $0.attr(HTMLRawText.Link.source.rawValue) }

    let highDefinitionSourceURL = sourceUrls.first { $0.contains(HTMLRawText.Video.high.rawValue) }

    return highDefinitionSourceURL ?? sourceUrls.first
  }

  func parseVideoElementThumbnailUrl() -> String? {
    try? parent()?.attr(HTMLRawText.Image.dataImage.rawValue)
  }

  func parseImageElement() -> ImageViewElement {
    var src = ""
    var caption: String?
    var href: String?

    if let parent = parent(),
      parent.tag().getName() == HTMLRawText.Link.anchor.rawValue {
      href = try? parent.attr(HTMLRawText.Link.link.rawValue)
    }

    caption = try? attr(HTMLRawText.Image.dataCaption.rawValue)

    let emptyChildren = children().isEmpty()
    let emptyChildrensChildren = !emptyChildren ? children()[0].children().isEmpty() : true

    if !emptyChildrensChildren {
      if let updatedSrc = try? children()[0].children()[0].attr(HTMLRawText.Link.source.rawValue) {
        src = updatedSrc
      }

      // - if it's a gif collect attribute data-src instead
      if src.contains(HTMLRawText.Image.gifExtension.rawValue),
        let updatedSrc = try? children()[0].children()[0].attr(HTMLRawText.Image.dataSource.rawValue) {
        src = updatedSrc
      }
    }

    return ImageViewElement(src: src, href: href, caption: caption)
  }

  func parseExternalElement() -> ExternalSourceViewElement {
    let children = children()

    guard !children.isEmpty(),
      let firstChildElementWithAttributeApplied = try? children[0]
      .attr(HTMLRawText.Base.width.rawValue, HTMLRawText.Size.hundredPercent.rawValue).text() else {
      return ExternalSourceViewElement(htmlContent: "")
    }

    let externalElementValue = ExternalSourceViewElement(htmlContent: firstChildElementWithAttributeApplied)

    return externalElementValue
  }

  /**
   * Each TextComponent will have:
   * - it's own list of styles to apply
   * - the url string in case the textComponent was a link
   * - the text to display
   */
  func parseTextElement(element: Element) -> TextComponent? {
    guard let text = try? text() else {
      return nil
    }

    var tagsOther = [String]()
    var urls = [String]()

    extractTextAttributes(element: element, tags: &tagsOther, urls: &urls)

    // - Extract from the list of styles `null` values and `LIST`, the list style is processed separately.
    var textStyleList = tagsOther.compactMap { TextComponent.TextStyleType(rawValue: $0) }
      .filter { $0 != .list }

    let href = urls.first ?? ""

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
          return !textNode.text().trimmed().isEmpty
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
