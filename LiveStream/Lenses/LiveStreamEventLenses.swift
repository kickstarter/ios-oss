// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent {
  public enum lens {
    public static let creator = Lens<LiveStreamEvent, LiveStreamEvent.Creator>(
      view: { $0.creator },
      set: { .init(id: $1.id, stream: $1.stream, creator: $0, firebase: $1.firebase,
        openTok: $1.openTok, user: $1.user) }
    )

    public static let firebase = Lens<LiveStreamEvent, LiveStreamEvent.Firebase>(
      view: { $0.firebase },
      set: { .init(id: $1.id, stream: $1.stream, creator: $1.creator, firebase: $0,
        openTok: $1.openTok, user: $1.user) }
    )

    public static let id = Lens<LiveStreamEvent, Int>(
      view: { $0.id },
      set: { .init(id: $0, stream: $1.stream, creator: $1.creator, firebase: $1.firebase,
        openTok: $1.openTok, user: $1.user) }
    )

    public static let openTok = Lens<LiveStreamEvent, LiveStreamEvent.OpenTok>(
      view: { $0.openTok },
      set: { .init(id: $1.id, stream: $1.stream, creator: $1.creator, firebase: $1.firebase,
        openTok: $0, user: $1.user) }
    )

    public static let stream = Lens<LiveStreamEvent, LiveStreamEvent.Stream>(
      view: { $0.stream },
      set: { .init(id: $1.id, stream: $0, creator: $1.creator, firebase: $1.firebase,
        openTok: $1.openTok, user: $1.user) }
    )

    public static let user = Lens<LiveStreamEvent, LiveStreamEvent.User>(
      view: { $0.user },
      set: { .init(id: $1.id, stream: $1.stream, creator: $1.creator, firebase: $1.firebase,
        openTok: $1.openTok, user: $0) }
    )
  }
}

extension LensType where Whole == LiveStreamEvent, Part == LiveStreamEvent.Stream {
  public var liveNow: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.liveNow
  }

  public var isRtmp: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.isRtmp
  }
}
