import SwiftSoup

enum ViewElementType: String {
  case image = "img"
  case text
  case video
  case externalSources = "iframe"
  case unknown

//    static func initialize(element: Element) -> ViewElementType {
//        let tag = element.tag().getName()
//
//      switch tag {
//      case tag == HTMLRawString.Link.anchor.rawValue:
//        element.children().first(where: <#T##(Element) throws -> Bool#>)
//      case
//      }
//
//        if tag == "div", let attributes = element.getAttributes() {
//            for attribute in attributes {
//                if attribute.getKey() == "class", attribute.getValue() == "template oembed" {
//                    return .oembed
//                }
//            }
//            return.unknown
//        } else if TextStyleType.initalize(tag: tag) == .link, !((try? element.getElementsByTag("img"))?.isEmpty() ?? true) {
//            return embeddedLink
//        } else if (TextStyleType.allCases.map { $0.rawValue }).contains(tag) {
//            return .text
//        } else if let type = ViewElementType(rawValue: tag) {
//            return type
//        } else {
//            return .unknown
//        }
//    }
}
