import Foundation

struct TextComponent {
  let text: String
  let link: String?
  let styles: [TextStyleType]

  // Direct body childs for text allows only TextBlockTypes
  enum TextBlockType: String, CaseIterable {
    case paragraph = "p"
    case header1 = "h1"
    case list = "ul"
  }

  // Styles to apply
  enum TextStyleType: String {
    case bold = "strong"
    case emphasis = "em"
    case list = "li"
    case listEnd = "</li>"
    case link = "a"
    case header = "h1"
  }
}
