// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.Firebase {
  public enum lens {
    public static let apiKey = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.apiKey },
      set: { .init(apiKey: $0, chatPath: $1.chatPath, greenRoomPath: $1.greenRoomPath,
        hlsUrlPath: $1.hlsUrlPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath, project: $1.project,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath ) }
    )

    public static let chatPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.chatPath },
      set: { .init(apiKey: $1.apiKey, chatPath: $0, greenRoomPath: $1.greenRoomPath,
        hlsUrlPath: $1.hlsUrlPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath, project: $1.project,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath ) }
    )

    public static let greenRoomPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.greenRoomPath },
      set: { .init(apiKey: $1.apiKey, chatPath: $1.chatPath, greenRoomPath: $0,
        hlsUrlPath: $1.hlsUrlPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath, project: $1.project,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath ) }
    )

    public static let hlsUrlPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.hlsUrlPath },
      set: { .init(apiKey: $1.apiKey, chatPath: $1.chatPath, greenRoomPath: $1.greenRoomPath,
        hlsUrlPath: $0, numberPeopleWatchingPath: $1.numberPeopleWatchingPath, project: $1.project,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath ) }
    )

    public static let numberPeopleWatchingPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.numberPeopleWatchingPath },
      set: { .init(apiKey: $1.apiKey, chatPath: $1.chatPath, greenRoomPath: $1.greenRoomPath,
        hlsUrlPath: $1.hlsUrlPath, numberPeopleWatchingPath: $0, project: $1.project,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath ) }
    )

    public static let project = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.project },
      set: { .init(apiKey: $1.apiKey, chatPath: $1.chatPath, greenRoomPath: $1.greenRoomPath,
        hlsUrlPath: $1.hlsUrlPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath, project: $0,
        scaleNumberPeopleWatchingPath: $1.scaleNumberPeopleWatchingPath ) }
    )

    public static let scaleNumberPeopleWatchingPath = Lens<LiveStreamEvent.Firebase, String>(
      view: { $0.scaleNumberPeopleWatchingPath },
      set: { .init(apiKey: $1.apiKey, chatPath: $1.chatPath, greenRoomPath: $1.greenRoomPath,
        hlsUrlPath: $1.hlsUrlPath, numberPeopleWatchingPath: $1.numberPeopleWatchingPath, project: $1.project,
        scaleNumberPeopleWatchingPath: $0 ) }
    )
  }
}
