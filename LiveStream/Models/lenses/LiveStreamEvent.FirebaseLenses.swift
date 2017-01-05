// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.Firebase {
  public enum lens {
    public static let apiKey = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.apiKey },
      set: { .init(project: $1.project, apiKey: $0, hlsUrlPath: $1.hlsUrlPath,
        greenRoomPath: $1.greenRoomPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath, chatPath: $1.chatPath) }
    )

    public static let chatPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.chatPath },
      set: { .init(project: $1.project, apiKey: $1.apiKey, hlsUrlPath: $1.hlsUrlPath,
        greenRoomPath: $1.greenRoomPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath, chatPath: $0) }
    )

    public static let greenRoomPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.greenRoomPath },
      set: { .init(project: $1.project, apiKey: $1.apiKey, hlsUrlPath: $1.hlsUrlPath,
        greenRoomPath: $0, numberPeopleWatchingPath: $1.numberPeopleWatchingPath,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath, chatPath: $1.chatPath) }
    )

    public static let hlsUrlPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.hlsUrlPath },
      set: { .init(project: $1.project, apiKey: $1.apiKey, hlsUrlPath: $0,
        greenRoomPath: $1.greenRoomPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath, chatPath: $1.chatPath) }
    )

    public static let numberPeopleWatchingPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.numberPeopleWatchingPath },
      set: { .init(project: $1.project, apiKey: $1.apiKey, hlsUrlPath: $1.hlsUrlPath,
        greenRoomPath: $1.greenRoomPath, numberPeopleWatchingPath: $0,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath, chatPath: $1.chatPath) }
    )

    public static let project = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.project },
      set: { .init(project: $0, apiKey: $1.apiKey, hlsUrlPath: $1.hlsUrlPath,
        greenRoomPath: $1.greenRoomPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath, chatPath: $1.chatPath) }
    )

    public static let scaleNumberPeopleWatchingPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.scaleNumberPeopleWatchingPath },
      set: { .init(project: $1.project, apiKey: $1.apiKey, hlsUrlPath: $1.hlsUrlPath,
        greenRoomPath: $1.greenRoomPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath,
        scaleNumberPeopleWatchingPath: $0, chatPath: $1.chatPath) }
    )
  }
}
