// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.Creator {
  public enum lens {
    public static let avatar = Lens<LiveStreamEvent.Creator, String>(
      view: { $0.avatar },
      set: { .init(name: $1.name, avatar: $0) }
    )

    public static let name = Lens<LiveStreamEvent.Creator, String>(
      view: { $0.name },
      set: { .init(name: $0, avatar: $1.avatar) }
    )
  }
}
