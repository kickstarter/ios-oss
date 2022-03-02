import CoreMedia
import Prelude

public struct VideoViewElement: HTMLViewElement {
  public let sourceURLString: String
  public let thumbnailURLString: String?
  public var seekPosition: CMTime
}

extension VideoViewElement {
  public enum lens {
    public static let seekPosition = Lens<VideoViewElement, CMTime>(
      view: { $0.seekPosition },
      set: { VideoViewElement(
        sourceURLString: $1.sourceURLString,
        thumbnailURLString: $1.thumbnailURLString,
        seekPosition: $0
      )
      }
    )
  }
}
