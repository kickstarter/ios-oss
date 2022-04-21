import CoreMedia
import Prelude

public struct AudioVideoViewElement: HTMLViewElement {
  public let sourceURLString: String
  public let thumbnailURLString: String?
  public var seekPosition: CMTime
}

extension AudioVideoViewElement {
  public enum lens {
    public static let seekPosition = Lens<AudioVideoViewElement, CMTime>(
      view: { $0.seekPosition },
      set: { AudioVideoViewElement(
        sourceURLString: $1.sourceURLString,
        thumbnailURLString: $1.thumbnailURLString,
        seekPosition: $0
      )
      }
    )
  }
}
