import Foundation
import GraphAPI

extension RichTextComponentFragment {
  public func asRichTextElements() -> [RichTextElement] {
    self.items.map { $0.asRichTextElement }
  }
}

extension RichTextComponentFragment.Item {
  var asRichTextElement: RichTextElement {
    if let x = asRichText { return x.asRichTextElement }
    if let x = asRichTextHeader { return x.asRichTextElement }
    if let x = asRichTextListItem { return x.asRichTextElement }
    if let x = asRichTextListOpen { return x.asRichTextElement }
    if let x = asRichTextListClose { return x.asRichTextElement }
    if let x = asRichTextPhoto { return x.asRichTextElement }
    if let x = asRichTextAudio { return x.asRichTextElement }
    if let x = asRichTextVideo { return x.asRichTextElement }
    if let x = asRichTextOembed { return x.asRichTextElement }
    assertionFailure("Could not detect a usable rich text element")
    return RichTextElement.unknown
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child {
  var asRichTextElement: RichTextElement {
    if let x = asRichText { return x.asRichTextElement }
    if let x = asRichTextHeader { return x.asRichTextElement }
    if let x = asRichTextListItem { return x.asRichTextElement }
    if let x = asRichTextListOpen { return x.asRichTextElement }
    if let x = asRichTextListClose { return x.asRichTextElement }
    if let x = asRichTextPhoto { return x.asRichTextElement }
    if let x = asRichTextAudio { return x.asRichTextElement }
    if let x = asRichTextVideo { return x.asRichTextElement }
    if let x = asRichTextOembed { return x.asRichTextElement }
    assertionFailure("Could not detect a usable rich text element")
    return RichTextElement.unknown
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child {
  var asRichTextElement: RichTextElement {
    if let x = asRichText { return x.asRichTextElement }
    if let x = asRichTextHeader { return x.asRichTextElement }
    if let x = asRichTextListItem { return x.asRichTextElement }
    if let x = asRichTextListOpen { return x.asRichTextElement }
    if let x = asRichTextListClose { return x.asRichTextElement }
    if let x = asRichTextPhoto { return x.asRichTextElement }
    if let x = asRichTextAudio { return x.asRichTextElement }
    if let x = asRichTextVideo { return x.asRichTextElement }
    if let x = asRichTextOembed { return x.asRichTextElement }
    assertionFailure("Could not detect a usable rich text element")
    return RichTextElement.unknown
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child {
  var asRichTextElement: RichTextElement {
    if let x = asRichText { return x.asRichTextElement }
    if let x = asRichTextHeader { return x.asRichTextElement }
    if let x = asRichTextListItem { return x.asRichTextElement }
    if let x = asRichTextListOpen { return x.asRichTextElement }
    if let x = asRichTextListClose { return x.asRichTextElement }
    if let x = asRichTextPhoto { return x.asRichTextElement }
    if let x = asRichTextAudio { return x.asRichTextElement }
    if let x = asRichTextVideo { return x.asRichTextElement }
    if let x = asRichTextOembed { return x.asRichTextElement }
    assertionFailure("Could not detect a usable rich text element")
    return RichTextElement.unknown
  }
}

extension RichTextComponentFragment.Item.AsRichText {
  var asRichTextElement: RichTextElement {
    let children = (children ?? []).map { $0.asRichTextElement }
    return .text(makeText(text: text, link: link, styles: styles, children: children), nil)
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichText {
  var asRichTextElement: RichTextElement {
    .text(makeText(text: text, link: link, styles: styles, children: []), nil)
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextHeader {
  var asRichTextElement: RichTextElement {
    .text(makeText(text: text, link: link, styles: styles, children: []), .init(styles: styles))
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListItem {
  var asRichTextElement: RichTextElement {
    .listItem(makeText(text: text, link: link, styles: styles, children: []))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader {
  var asRichTextElement: RichTextElement {
    let children = (children ?? []).map { $0.asRichTextElement }
    return .text(makeText(text: text, link: link, styles: styles, children: children), .init(styles: styles))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichText {
  var asRichTextElement: RichTextElement {
    .text(makeText(text: text, link: link, styles: styles, children: []), nil)
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextHeader {
  var asRichTextElement: RichTextElement {
    .text(makeText(text: text, link: link, styles: styles, children: []), .init(styles: styles))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListItem {
  var asRichTextElement: RichTextElement {
    .listItem(makeText(text: text, link: link, styles: styles, children: []))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem {
  var asRichTextElement: RichTextElement {
    let children = (children ?? []).map { $0.asRichTextElement }
    return .listItem(makeText(text: text, link: link, styles: styles, children: children))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichText {
  var asRichTextElement: RichTextElement {
    .text(makeText(text: text, link: link, styles: styles, children: []), nil)
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextHeader {
  var asRichTextElement: RichTextElement {
    .text(makeText(text: text, link: link, styles: styles, children: []), .init(styles: styles))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListItem {
  var asRichTextElement: RichTextElement {
    .listItem(makeText(text: text, link: link, styles: styles, children: []))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListOpen {
  var asRichTextElement: RichTextElement {
    .listItemOpen
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListOpen {
  var asRichTextElement: RichTextElement {
    .listItemOpen
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListOpen {
  var asRichTextElement: RichTextElement {
    .listItemOpen
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListOpen {
  var asRichTextElement: RichTextElement {
    .listItemOpen
  }
}

extension RichTextComponentFragment.Item.AsRichTextListClose {
  var asRichTextElement: RichTextElement {
    .listItemClose
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListClose {
  var asRichTextElement: RichTextElement {
    .listItemClose
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListClose {
  var asRichTextElement: RichTextElement {
    .listItemClose
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListClose {
  var asRichTextElement: RichTextElement {
    .listItemClose
  }
}

extension RichTextComponentFragment.Item.AsRichTextAudio {
  var asRichTextElement: RichTextElement {
    .audio(RichTextElement.Audio(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextAudio {
  var asRichTextElement: RichTextElement {
    .audio(RichTextElement.Audio(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextAudio {
  var asRichTextElement: RichTextElement {
    .audio(RichTextElement.Audio(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextAudio {
  var asRichTextElement: RichTextElement {
    .audio(RichTextElement.Audio(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextPhoto {
  var asRichTextElement: RichTextElement {
    .photo(RichTextElement.Photo(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextPhoto {
  var asRichTextElement: RichTextElement {
    .photo(RichTextElement.Photo(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextPhoto {
  var asRichTextElement: RichTextElement {
    .photo(RichTextElement.Photo(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextPhoto {
  var asRichTextElement: RichTextElement {
    .photo(RichTextElement.Photo(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextVideo {
  var asRichTextElement: RichTextElement {
    .video(RichTextElement.Video(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextVideo {
  var asRichTextElement: RichTextElement {
    .video(RichTextElement.Video(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextVideo {
  var asRichTextElement: RichTextElement {
    .video(RichTextElement.Video(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextVideo {
  var asRichTextElement: RichTextElement {
    .video(RichTextElement.Video(
      altText: altText,
      assetID: asset?.id,
      caption: caption,
      url: url
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextOembed {
  var asRichTextElement: RichTextElement {
    .oembed(RichTextElement.Oembed(
      width: width,
      height: height,
      version: version,
      title: title,
      type: type,
      iframeUrl: iframeUrl,
      originalUrl: originalUrl,
      thumbnailUrl: thumbnailUrl,
      thumbnailWidth: thumbnailWidth,
      thumbnailHeight: thumbnailHeight
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichText.Child.AsRichTextOembed {
  var asRichTextElement: RichTextElement {
    .oembed(RichTextElement.Oembed(
      width: width,
      height: height,
      version: version,
      title: title,
      type: type,
      iframeUrl: iframeUrl,
      originalUrl: originalUrl,
      thumbnailUrl: thumbnailUrl,
      thumbnailWidth: thumbnailWidth,
      thumbnailHeight: thumbnailHeight
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextOembed {
  var asRichTextElement: RichTextElement {
    .oembed(RichTextElement.Oembed(
      width: width,
      height: height,
      version: version,
      title: title,
      type: type,
      iframeUrl: iframeUrl,
      originalUrl: originalUrl,
      thumbnailUrl: thumbnailUrl,
      thumbnailWidth: thumbnailWidth,
      thumbnailHeight: thumbnailHeight
    ))
  }
}

extension RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextOembed {
  var asRichTextElement: RichTextElement {
    .oembed(RichTextElement.Oembed(
      width: width,
      height: height,
      version: version,
      title: title,
      type: type,
      iframeUrl: iframeUrl,
      originalUrl: originalUrl,
      thumbnailUrl: thumbnailUrl,
      thumbnailWidth: thumbnailWidth,
      thumbnailHeight: thumbnailHeight
    ))
  }
}

private func makeTextElement(
  text: String?,
  link: String?,
  styles: [RichTextElement.Text.Style]?,
  children: [RichTextElement]
) -> RichTextElement.Text {
  RichTextElement.Text(
    text: text ?? "",
    link: link.flatMap { URL(string: $0) },
    styles: styles ?? [],
    children: children
  )
}

private func makeText(
  text: String?,
  link: String?,
  styles: [String]?,
  children: [RichTextElement]
) -> RichTextElement.Text {
  makeTextElement(
    text: text,
    link: link,
    styles: styles?.compactMap(RichTextElement.Text.Style.init(rawValue:)),
    children: children
  )
}
