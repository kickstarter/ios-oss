// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent {
  public enum lens {
    public static let creator = Lens<LiveStreamEvent, LiveStreamEvent.Creator>(
      view: { $0.creator },
      set: { .init(creator: $0, firebase: $1.firebase, id: $1.id, openTok: $1.openTok, stream: $1.stream,
        user: $1.user) }
    )

    public static let firebase = Lens<LiveStreamEvent, LiveStreamEvent.Firebase>(
      view: { $0.firebase },
      set: { .init(creator: $1.creator, firebase: $0, id: $1.id, openTok: $1.openTok, stream: $1.stream,
        user: $1.user) }
    )

    public static let id = Lens<LiveStreamEvent, Int>(
      view: { $0.id },
      set: { .init(creator: $1.creator, firebase: $1.firebase, id: $0, openTok: $1.openTok, stream: $1.stream,
        user: $1.user) }
    )

    public static let openTok = Lens<LiveStreamEvent, LiveStreamEvent.OpenTok?>(
      view: { $0.openTok },
      set: { .init(creator: $1.creator, firebase: $1.firebase, id: $1.id, openTok: $0, stream: $1.stream,
        user: $1.user) }
    )

    public static let stream = Lens<LiveStreamEvent, LiveStreamEvent.Stream>(
      view: { $0.stream },
      set: { .init(creator: $1.creator, firebase: $1.firebase, id: $1.id, openTok: $1.openTok, stream: $0,
        user: $1.user) }
    )

    public static let user = Lens<LiveStreamEvent, LiveStreamEvent.User>(
      view: { $0.user },
      set: { .init(creator: $1.creator, firebase: $1.firebase, id: $1.id, openTok: $1.openTok, stream:
        $1.stream, user: $0) }
    )
  }
}

extension LensType where Whole == LiveStreamEvent, Part == LiveStreamEvent.Stream {
  public var description: Lens<LiveStreamEvent, String> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.description
  }

  public var hasReplay: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.hasReplay
  }

  public var hlsUrl: Lens<LiveStreamEvent, String?> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.hlsUrl
  }

  public var isRtmp: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.isRtmp
  }

  public var isScale: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.isScale
  }

  public var liveNow: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.liveNow
  }

  public var maxOpenTokViewers: Lens<LiveStreamEvent, Int> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.maxOpenTokViewers
  }

  public var name: Lens<LiveStreamEvent, String> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.name
  }

  public var projectName: Lens<LiveStreamEvent, String> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.projectName
  }

  public var replayUrl: Lens<LiveStreamEvent, String?> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.replayUrl
  }

  public var startDate: Lens<LiveStreamEvent, Date> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.startDate
  }

  public var webUrl: Lens<LiveStreamEvent, String> {
    return LiveStreamEvent.lens.stream • LiveStreamEvent.Stream.lens.webUrl
  }
}

extension LensType where Whole == LiveStreamEvent, Part == LiveStreamEvent.User {
  public var isSubscribed: Lens<LiveStreamEvent, Bool> {
    return LiveStreamEvent.lens.user • LiveStreamEvent.User.lens.isSubscribed
  }
}

extension LensType where Whole == LiveStreamEvent, Part == LiveStreamEvent.Creator {
  public var avatar: Lens<LiveStreamEvent, String> {
    return LiveStreamEvent.lens.creator • LiveStreamEvent.Creator.lens.avatar
  }
}
