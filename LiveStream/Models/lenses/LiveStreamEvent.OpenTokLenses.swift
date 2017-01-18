// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.OpenTok {
  public enum lens {
    public static let appId = Lens<LiveStreamEvent.OpenTok, String>(
      view: { $0.appId },
      set: { .init(appId: $0, sessionId: $1.sessionId, token: $1.token) }
    )

    public static let sessionId = Lens<LiveStreamEvent.OpenTok, String>(
      view: { $0.sessionId },
      set: { .init(appId: $1.appId, sessionId: $0, token: $1.token) }
    )

    public static let token = Lens<LiveStreamEvent.OpenTok, String>(
      view: { $0.token },
      set: { .init(appId: $1.appId, sessionId: $1.sessionId, token: $0) }
    )
  }
}
