import Foundation

class EmbeddedLinkViewElement: ImageViewElement {
  let caption: String?
  let href: String

  var attributedText: NSMutableAttributedString? {
    guard let caption = self.caption else { return nil }
    let string = NSMutableAttributedString()
    string.append(NSAttributedString(string: caption, attributes: [TextStyleType.caption].attributes))
    return string
  }

  init(href: String, src: String, caption: String?) {
    self.caption = caption
    self.href = href
    super.init(src: src)
  }
}
