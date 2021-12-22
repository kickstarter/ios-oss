import Foundation

struct TextComponent: Codable, CustomStringConvertible, Equatable {
    let text: String
    let link: String?
    let styles: [TextStyleType]

    init(text: String, link: String?, styles: [TextStyleType]) {
        self.text = text
        self.link = link
        self.styles = styles
    }

    var description: String {
        return """
        Text Component: \(text)
        \(link ?? "")
        \(styles)
        """
    }
}
