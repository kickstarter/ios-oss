import Foundation
import UIKit

extension String {
  typealias Attributes = [String:AnyObject]

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

      let string: NSMutableAttributedString
      let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
      do {
        string = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
      } catch {
        return nil
      }

      // Sub all bold and italic fonts in the attributed html string
      let stringRange = NSMakeRange(0, string.length)
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
  func simpleHtmlAttributedString(
    font font: UIFont,
    bold optionalBold: UIFont? = nil,
    italic optionalItalic: UIFont? = nil) -> NSAttributedString? {

      return self.simpleHtmlAttributedString(
        base: [NSFontAttributeName: font],
        bold: optionalBold.flatMap { [NSFontAttributeName: $0] },
        italic: optionalItalic.flatMap { [NSFontAttributeName: $0] }
      )
  }
}
