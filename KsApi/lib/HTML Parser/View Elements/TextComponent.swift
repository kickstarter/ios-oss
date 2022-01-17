import Foundation

public struct TextComponent: Decodable {
  public let text: String
  public let link: String?
  public let styles: [TextStyleType]

  // Direct body childs for text allows only TextBlockTypes
  enum TextBlockType: String, CaseIterable, Decodable {
    case paragraph = "p"
    case header1 = "h1"
    case list = "ul"
  }

  // Styles to apply
  public enum TextStyleType: String, Decodable {
    case bold = "strong"
    case emphasis = "em"
    case list = "li"
    case listEnd = "</li>"
    case link = "a"
    case header = "h1"
  }
}
