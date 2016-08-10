import UIKit
import Foundation

public extension String {
  public typealias Attributes = [String:AnyObject]

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
  public func simpleHtmlAttributedString(
    base base: Attributes,
         bold optionalBold: Attributes? = nil,
              italic optionalItalic: Attributes? = nil) -> NSAttributedString? {
    let baseFont = base[NSFontAttributeName] ?? UIFont.systemFontOfSize(12.0)

    // If bold or italic are not specified we can derive them from `font`.
    let bold = optionalBold ?? [NSFontAttributeName: UIFont(
      descriptor: baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits([.TraitBold]),
      size: baseFont.pointSize
      )]
    let italic = optionalItalic ?? [NSFontAttributeName: UIFont(
      descriptor: baseFont.fontDescriptor().fontDescriptorWithSymbolicTraits([.TraitItalic]),
      size: baseFont.pointSize
      )]

    guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }

    let options: [String:AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
    ]
    guard let string = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
      else {
        return nil
    }

    // Sub all bold and italic fonts in the attributed html string
    let stringRange = NSRange(location: 0, length: string.length)
    string.beginEditing()
    string.enumerateAttribute(NSFontAttributeName, inRange: stringRange, options: []) { value, range, stop in

      guard let htmlFont = value as? UIFont else { return }
      let newAttributes: Attributes

      if htmlFont.fontDescriptor().symbolicTraits.contains(.TraitBold) {
        newAttributes = bold
      } else if htmlFont.fontDescriptor().symbolicTraits.contains(.TraitItalic) {
        newAttributes = italic
      } else {
        newAttributes = base
      }

      string.addAttributes(newAttributes, range: range)
    }
    string.endEditing()

    return string
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
  public func simpleHtmlAttributedString(
    font font: UIFont,
         bold optionalBold: UIFont? = nil,
              italic optionalItalic: UIFont? = nil) -> NSAttributedString? {

    return self.simpleHtmlAttributedString(
      base: [NSFontAttributeName: font],
      bold: optionalBold.flatMap { [NSFontAttributeName: $0] },
      italic: optionalItalic.flatMap { [NSFontAttributeName: $0] })
  }

  /**
   Removes all HTML from `self`.

   - parameter trimWhitespace: If `true`, then all whitespace will be trimmed from the stripped string.
                               Defaults to `true`.

   - returns: A string with all HTML stripped.
   */
  public func htmlStripped(trimWhitespace trimWhitespace: Bool = true) -> String? {

    guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }

    let options: [String:AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
    ]

    let string = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    let result = string?.string

    if trimWhitespace {
      return result?.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
    }
    return result
  }
}
