import Foundation
import UIKit

enum TextStyleType: String, Codable, CustomStringConvertible, CaseIterable {
  case paragraph = "p"
  case header1 = "h1"
  case bold = "strong"
//    case br = "br"
  case link = "a"
  case emphasis = "em"
  case caption = "figcaption"
  case list = "li"
  case unknown

  static func initalize(tag: String) -> TextStyleType {
    return TextStyleType(rawValue: tag) ?? .unknown
  }

  var description: String {
    return """
    Text Style: \(rawValue)
    """
  }

  var fontTrait: UIFontDescriptor.SymbolicTraits? {
    switch self {
    case .bold:
      return .traitBold
    case .emphasis, .caption:
      return .traitItalic
    default:
      return nil
    }
  }

  var fontSize: CGFloat {
    switch self {
    case .header1:
      return 24
    case .caption:
      return UIFont.systemFontSize - 2
    default:
      return UIFont.systemFontSize
    }
  }

  var textAlignment: NSTextAlignment {
    switch self {
    case .caption:
      return .center
    default:
      return .natural
    }
  }

  var customAttributes: [NSAttributedString.Key: Any] {
    switch self {
    case .link:
      return [NSAttributedString.Key.underlineStyle: 2]
    default:
      return [:]
    }
  }
}
