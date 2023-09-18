import Library
import SwiftUI

extension Text {
  /// Allows Text to be initialized with a string that has html. Option to sepcify a portion of the string that should be a hyperlink.
  @available(iOS 15, *)
  init(html: String, with hyperlink: ReportProjectHyperLinkType) {
    do {
      var attrString = try html.htmlToAttributedString()
      attrString.font = .ksr_subhead()

      if let range = attrString.range(of: hyperlink.stringLiteral(), options: .caseInsensitive) {
        attrString[range].foregroundColor = .green
      }

      self.init(attrString)

    } catch {
      print("Error initializing attributed string from text that contains HTML: \(html)")
      self.init("")
    }
  }
}
