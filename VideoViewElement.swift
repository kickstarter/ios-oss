import Foundation

class VideoViewElement: Codable, ViewElement, CustomStringConvertible {
  let sourceUrls: [String]

  var description: String {
    return """
    Video View Element:
    \(self.sourceUrls)
    """
  }

  init(sourceUrls: [String]) {
    self.sourceUrls = sourceUrls
  }
}
