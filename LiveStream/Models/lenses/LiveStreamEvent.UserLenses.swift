// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.User {
  public enum lens {
    public static let isSubscribed = Lens<LiveStreamEvent.User, Bool>(
      view: { $0.isSubscribed },
      set: { isSubscribed, _ in LiveStreamEvent.User(isSubscribed: isSubscribed) }
    )
  }
}
