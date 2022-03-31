import Foundation
import SwiftSoup

extension Element {
  func extractViewElementTypeFromDiv() -> ViewElementType? {
    var type: ViewElementType?

    if self.isImageAudioOrVideoStructure() {
      type = .imageAudioOrVideo
    } else if self.isIframeStructure() {
      type = .externalSources
    }

    return type
  }

  private func isIframeStructure() -> Bool {
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

  private func isImageAudioOrVideoStructure() -> Bool {
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

  func parseAudioElement() -> String? {
    let sourceUrls = children().compactMap { try? $0.attr(HTMLRawText.Link.source.rawValue) }

    return sourceUrls.first
  }

  func parseAudioVideoElementThumbnailUrl() -> String? {
    try? parent()?.attr(HTMLRawText.Image.dataImage.rawValue)
  }

  func parseImageElement() -> ImageViewElement? {
    var src = ""
    var caption: String?
    var href: String?

    if let parent = parent(),
      parent.tag().getName() == HTMLRawText.Link.anchor.rawValue {
      href = try? parent.attr(HTMLRawText.Link.link.rawValue)
    }

    guard let childValue = children().first,
      let _ = childValue.children().first else {
      return nil
    }

    caption = try? attr(HTMLRawText.Image.dataCaption.rawValue)

    src = self.parseImageElementSrc()

    let value = src.isEmpty ? nil : ImageViewElement(src: src, href: href, caption: caption)

    return value
  }

  func parseExternalElement() -> ExternalSourceViewElement {
    var contentString = ""
    var contentHeight: Int?

    guard let iFrameElement = try? children().first()?.getElementsByTag(HTMLRawText.Base.iframe.rawValue)
      .first(),
      let iFrameSourceString = iFrameElement.getAttributes()?
      .first(where: { $0.getKey() == HTMLRawText.Link.source.rawValue })?.getValue() else {
      return ExternalSourceViewElement(
        embeddedURLString: contentString,
        embeddedURLContentHeight: contentHeight
      )
    }

    /// Ensure content that is embedded can be parsed for a src tag.
    contentString = iFrameSourceString

    if let urlComponents = URLComponents(string: iFrameSourceString),
      let srcQueryItemValue = urlComponents.queryItems?
      .first(where: { $0.name == HTMLRawText.Link.source.rawValue })?.value {
      contentString = srcQueryItemValue
    }

    guard let heightAttributeText: String = iFrameElement.getAttributes()?
      .first(where: { $0.getKey() == HTMLRawText.Base.height.rawValue })?.getValue(),
      let contentHeightValue = Int(heightAttributeText) else {
      return ExternalSourceViewElement(
        embeddedURLString: contentString,
        embeddedURLContentHeight: contentHeight
      )
    }

    contentHeight = contentHeightValue

    let externalElementValue = ExternalSourceViewElement(
      embeddedURLString: contentString,
      embeddedURLContentHeight: contentHeight
    )

    return externalElementValue
  }

  private func parseImageElementSrc() -> String {
    var updatedSrc = ""
    let child = children()[0].children()[0]

    if let source = try? child.attr(HTMLRawText.Link.source.rawValue) {
      updatedSrc = source
    }

    // - if it's a gif collect attribute data-src instead
    if updatedSrc.contains(HTMLRawText.Image.gifExtension.rawValue),
      let dataSource = try? child.attr(HTMLRawText.Image.dataSource.rawValue) {
      updatedSrc = dataSource
    }

    return updatedSrc
  }
}
