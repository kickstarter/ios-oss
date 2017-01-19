// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.BackgroundImage {
  public enum lens {
    public static let smallCropped = Lens<LiveStreamEvent.BackgroundImage, String>(
      view: { $0.smallCropped },
      set: { LiveStreamEvent.BackgroundImage(medium: $1.medium, smallCropped: $0) }
    )
  }
}

extension LensType where Whole == LiveStreamEvent, Part == LiveStreamEvent.BackgroundImage {
  public var smallCropped: Lens<Whole, String> {
    return LiveStreamEvent.lens.backgroundImage • LiveStreamEvent.BackgroundImage.lens.smallCropped
  }
}
