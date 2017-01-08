// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.Creator {
  public enum lens {
    public static let avatar = Lens<LiveStreamEvent.Creator, String>(
      view: { $0.avatar },
      set: { .init(avatar: $0, name: $1.name) }
    )

    public static let name = Lens<LiveStreamEvent.Creator, String>(
      view: { $0.name },
      set: { .init(avatar: $1.avatar, name: $0) }
    )
  }
}
