import Foundation

public struct VideoViewElement: HTMLViewElement {
  let sourceUrl: String
  let thumbnailUrl: String?
  let seekPosition: Int64
}
