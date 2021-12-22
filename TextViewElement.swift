import Foundation

class TextViewElement: Codable, ViewElement, CustomStringConvertible {
    var components: [TextComponent]

    var attributedText: NSMutableAttributedString {
        let string = NSMutableAttributedString()
        for component in components {
            let prefixString = component == components.first ? component.styles.prefix : ""
            string.append(NSAttributedString(string: "\(prefixString)\(component.text)",
                                             attributes: component.styles.attributes))
        }
        return string
    }

    var description: String {
        var text = "=== Text View Element: ==="
        components.forEach { text.append("\n\n" + $0.description) }
        text.append("\n\n=== Text View Element: ===")
        return text
    }

    init(components: [TextComponent]) {
        self.components = components
    }
}
