import Foundation

public struct TextComponent {
  public let text: String
  public let link: String?
  public let styles: [TextStyleType]

  // Direct body childs for text allows only TextBlockTypes
  enum TextBlockType: String, CaseIterable {
    case paragraph = "p"
    case header1 = "h1"
    case header2 = "h2"
    case header3 = "h3"
    case header4 = "h4"
    case header5 = "h5"
    case header6 = "h6"
    case unorderedList = "ul"
    case orderedList = "ol"
  }

  // Styles to apply
  public enum TextStyleType: String {
    case bold = "strong"
    case emphasis = "em"
    case bulletStart = "li"
    case bulletEnd = "</li>"
    case link = "a"
    case header1 = "h1"
    case header2 = "h2"
    case header3 = "h3"
    case header4 = "h4"
    case header5 = "h5"
    case header6 = "h6"
  }
}
