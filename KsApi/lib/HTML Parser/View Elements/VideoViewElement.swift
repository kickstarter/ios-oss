import CoreMedia
import Prelude

public struct VideoViewElement: HTMLViewElement {
  public let sourceUrlString: String
  public let thumbnailUrlString: String?
  public var seekPosition: CMTime
}

extension VideoViewElement {
  public enum lens {
    public static let seekPosition = Lens<VideoViewElement, CMTime>(
      view: { $0.seekPosition },
      set: { VideoViewElement(
        sourceUrlString: $1.sourceUrlString,
        thumbnailUrlString: $1.thumbnailUrlString,
        seekPosition: $0
      )
      }
    )
  }
}
