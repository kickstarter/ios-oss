import Foundation
import KDS
import SwiftSoup
import SwiftUI
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
      let baseFont = (base[NSAttributedString.Key.font] as? UIFont) ?? UIFont.ksr_caption1()

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

   - returns: A string with all HTML stripped.
   */
  func htmlStripped() -> String? {
    do {
      let doc = try SwiftSoup.parse(self)
      // The old NSAttributedString parser turned certain tags (like <p> and <li>)into newlines.
      // Insert newlines into the HTML to mimic that.
      let linebreaks = try doc.select("p, li, h1, h2, h3")
      try linebreaks.before("\n")

      // Trim the HTML, but don't remove excess whitespace.
      // This preserves the newlines we just added.
      let plainText = try doc.text(trimAndNormaliseWhitespace: false)

      // SwiftSoup adds a space between each element when it strips the HTML.
      // Remove those spaces if they're added after our new newline,
      // and trim any whitespace at the beginning or end of the string.
      return plainText
        .replacingOccurrences(of: "\n ", with: "\n")
        .replacingOccurrences(of: " \n", with: "\n")
        .trimmed()
    } catch {
      return nil
    }
  }

  /// Returns `true` if the string contains at least one `<a href>` anchor tag.
  var containsHTMLLink: Bool {
    guard let doc = try? SwiftSoup.parse(self),
          let links = try? doc.select("a[href]") else {
      return false
    }

    return !links.isEmpty()
  }

  /// Returns the string with all HTML tags removed.
  /// Used as a fallback for strings that contain unexpected HTML but no links. (found this issue in a case where we received a <span> from the backend for a string that we didn't have a localized translated string for).
  var htmlTagsRemoved: String {
    guard let doc = try? SwiftSoup.parse(self),
          let body = doc.body(),
          let text = try? body.text() else {
      return self
    }

    return text
  }

  /// Converts `<a href="...">` to Markdown and strips remaining HTML tags.
  func htmlToMarkdown() -> String {
    guard let doc = try? SwiftSoup.parse(self),
          let body = doc.body() else {
      return self
    }

    /// Replace each anchor with its Markdown equivalent before replacing tags
    if let anchors = try? body.select("a[href]") {
      for anchor in anchors {
        let href = (try? anchor.attr("href")) ?? ""
        let text = (try? anchor.text()) ?? ""

        try? anchor.replaceWith(TextNode("[\(text)](\(href))", nil))
      }
    }

    /// body.text() strips all remaining HTML tags
    return (try? body.text()) ?? self
  }

  /// Converts HTML to an `AttributedString` by first parsing with SwiftSoup,
  /// then rendering the result using Swift's built in Markdown parser.
  /// Should be safe to call from SwiftUI view bodies. No WebKit, no main thread blocking.
  /// All `<a href>` links are then rendered in `Colors.Text.Accent.green`.
  func htmlAttributedString(font: UIFont, baseColor: Color) -> AttributedString {
    let markdown = self.htmlToMarkdown()

    var str = (try? AttributedString(
      markdown: markdown,
      options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
    )) ?? AttributedString(markdown)

    str.font = Font(font)
    str.foregroundColor = baseColor

    /// Collect link ranges first, then add color
    let linkRanges = str.runs.filter { $0.link != nil }.map { $0.range }

    for range in linkRanges {
      str[range].foregroundColor = Colors.Text.Accent.green.swiftUIColor()
    }

    return str
  }
}

// MARK: - Functions

func == (lhs: String.Attributes, rhs: String.Attributes) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
