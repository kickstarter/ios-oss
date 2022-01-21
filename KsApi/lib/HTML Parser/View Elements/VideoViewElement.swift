import Foundation

public struct VideoViewElement: Decodable {
  let sourceUrl: String
  let thumbnailUrl: String?
  let seekPosition: Int64
}
