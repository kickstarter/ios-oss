import Foundation
import KsApi

public protocol HasVideoViewProperties {
  var videoViewProperties: VideoViewProperties { get }
}

public typealias VideoViewConfiguration =
  HasProjectAnalyticsProperties & HasProjectWebURL & HasVideoViewProperties

public struct VideoViewProperties {
  public let video: (hls: String?, high: String)?
  public let photoFull: String

  public init(video: (hls: String?, high: String)?, photoFull: String) {
    self.video = video
    self.photoFull = photoFull
  }
}

extension Project: HasVideoViewProperties {
  public var videoViewProperties: VideoViewProperties {
    VideoViewProperties(
      video: self.video.map { ($0.hls, $0.high) },
      photoFull: self.photo.full
    )
  }
}
