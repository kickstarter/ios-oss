import Foundation

public struct VideoViewElement: ViewElement {
  let sourceUrl: String
  let thumbnailUrl: String?
  let seekPosition: Int64
}
