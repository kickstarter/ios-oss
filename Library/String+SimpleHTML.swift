import Foundation
import UIKit

public extension String {
  typealias Attributes = [NSAttributedString.Key: Any]

  /**
   Interprets `self` as an HTML string to produce an attributed string.

   - parameter base:   The base attributes to use for the attributed string.
   - parameter bold:   Optional attributes to use on bold tags. If not specified it will be derived
   from `font`.
   - parameter italic: Optional attributes for use on italic tags. If not specified it will be derived
   from `font`.

   - returns: The attributed string, or `nil` if something goes wrong with interpreting the string
   as html.
   */
  func simpleHtmlAttributedString(
    base: Attributes,
    bold optionalBold: Attributes? = nil,
    italic optionalItalic: Attributes? = nil
  ) -> NSAttributedString? {
    func parsedHtml() -> NSAttributedString? {
      let baseFont = (base[NSAttributedString.Key.font] as? UIFont) ?? UIFont.systemFont(ofSize: 12.0)

      // If bold or italic are not specified we can derive them from `font`.
      let bold = optionalBold ?? [NSAttributedString.Key.font: baseFont.bolded]
      let italic = optionalItalic ?? [NSAttributedString.Key.font: baseFont.italicized]

      guard let data = self.data(using: String.Encoding.utf8) else { return nil }

      let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
      ]
      guard let string = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
      else {
        return nil
      }

      // Sub all bold and italic fonts in the attributed html string
      let stringRange = NSRange(location: 0, length: string.length)
      string.beginEditing()
      string
        .enumerateAttribute(NSAttributedString.Key.font, in: stringRange, options: []) { value, range, _ in

          guard let htmlFont = value as? UIFont else { return }
          let newAttributes: Attributes

          if htmlFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
            newAttributes = bold
          } else if htmlFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            newAttributes = italic
          } else {
            newAttributes = base
          }

          string.addAttributes(newAttributes, range: range)
        }
      string.endEditing()

      return string
    }

    if Thread.isMainThread {
      return parsedHtml()
    } else {
      return DispatchQueue.main.sync {
        parsedHtml()
      }
    }
  }

  /**
   Interprets `self` as an HTML string to produce an attributed string.

   - parameter font:   The base font to use for the attributed string.
   - parameter bold:   An optional font for bolding. If not specified it will be derived from `font`.
   - parameter italic: An optional font for italicizing. If not specified it will be derived
                       from `font`.

   - returns: The attributed string, or `nil` if something goes wrong with interpreting the string
              as html.
   */
  func simpleHtmlAttributedString(
    font: UIFont,
    bold optionalBold: UIFont? = nil,
    italic optionalItalic: UIFont? = nil
  ) -> NSAttributedString? {
    return self.simpleHtmlAttributedString(
      base: [NSAttributedString.Key.font: font],
      bold: optionalBold.flatMap { [NSAttributedString.Key.font: $0] },
      italic: optionalItalic.flatMap { [NSAttributedString.Key.font: $0] }
    )
  }

  /**
   Removes all HTML from `self`.

   - parameter trimWhitespace: If `true`, then all whitespace will be trimmed from the stripped string.
                               Defaults to `true`.

   - returns: A string with all HTML stripped.
   */
  func htmlStripped(trimWhitespace: Bool = true) -> String? {
    func parsedHtml() -> String? {
      guard let data = self.data(using: String.Encoding.utf8) else { return nil }

      let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
      ]

      let string = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
      let result = string?.string

      if trimWhitespace {
        return result?.trimmingCharacters(in: .whitespacesAndNewlines)
      }
      return result
    }

    if Thread.isMainThread {
      return parsedHtml()
    } else {
      return DispatchQueue.main.sync {
        parsedHtml()
      }
    }
  }
}

// MARK: - Functions

func == (lhs: String.Attributes, rhs: String.Attributes) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
