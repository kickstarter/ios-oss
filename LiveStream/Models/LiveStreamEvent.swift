import Argo
import Curry

public struct LiveStreamEvent: Equatable {
  // FIXME: Alphabetize
  public let id: Int
  public let stream: Stream
  public let creator: Creator
  public let firebase: Firebase
  public let openTok: OpenTok
  public let user: User

  public struct Stream {
    public let name: String
    public let description: String
    public let hlsUrl: String // TODO: ask justin if this is guaranteed?
    public let liveNow: Bool
    public let startDate: NSDate
    public let backgroundImageUrl: String
    public let maxOpenTokViewers: Int
    public let webUrl: String
    public let projectWebUrl: String
    public let projectName: String
    public let isRtmp: Bool
    public let isScale: Bool
    public let hasReplay: Bool
    public let replayUrl: String?
  }

  public struct Creator {
    public let name: String
    public let avatar: String
  }

  public struct Firebase {
    public let project: String
    public let apiKey: String
    public let hlsUrlPath: String
    public let greenRoomPath: String
    public let numberPeopleWatchingPath: String
    public let scaleNumberPeopleWatchingPath: String
    public let chatPath: String
  }

  public struct OpenTok {
    public let appId: String
    public let sessionId: String
    public let token: String
  }

  public struct User {
    public let isSubscribed: Bool
  }
}

public func == (lhs: LiveStreamEvent, rhs: LiveStreamEvent) -> Bool {
  return lhs.id == rhs.id
}

extension LiveStreamEvent: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent> {
    return curry(LiveStreamEvent.init)
      <^> json <| "id"
      <*> json <| "stream"
      // FIXME: can just use `json <| "key"` on all of these
      <*> Creator.decode(json)
      <*> Firebase.decode(json)
      <*> OpenTok.decode(json)
//      <*> User.decode(json)
      <*> json <| "user" <|> .Success(User(isSubscribed: false))
  }
}

extension LiveStreamEvent.Stream: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.Stream> {
    let create = curry(LiveStreamEvent.Stream.init)
    let tmp1 = create
      <^> json <| "name"
      <*> json <| "description"
      <*> json <| "hls_url"
      <*> json <| "live_now"
      <*> (json <| "start_date" >>- toDate)
      <*> json <| "background_image_url"
      <*> json <| "max_opentok_viewers"

    let tmp2 = tmp1
      <*> json <| "web_url"
      <*> json <| "project_web_url"
      <*> json <| "project_name"
      <*> json <| "is_rtmp"
      <*> json <| "is_scale"
      <*> json <| "has_replay"
      <*> json <|? "replay_url"

    return tmp2
  }
}

extension LiveStreamEvent.Creator: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.Creator> {
    return curry(LiveStreamEvent.Creator.init)
      // FIXME: can get rid of the `"creator"` key prefix
      <^> json <| ["creator", "creator_name"]
      <*> json <| ["creator", "creator_avatar"]
  }
}

extension LiveStreamEvent.Firebase: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.Firebase> {
    return curry(LiveStreamEvent.Firebase.init)
      <^> json <| ["firebase", "firebase_project"]
      <*> json <| ["firebase", "firebase_api_key"]
      <*> json <| ["firebase", "hls_url_path"]
      <*> json <| ["firebase", "green_room_path"]
      <*> json <| ["firebase", "number_people_watching_path"]
      <*> json <| ["firebase", "scale_number_people_watching_path"]
      <*> json <| ["firebase", "chat_path"]
  }
}

extension LiveStreamEvent.OpenTok: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.OpenTok> {
    return curry(LiveStreamEvent.OpenTok.init)
      <^> json <| ["opentok", "app"]
      <*> json <| ["opentok", "session"]
      <*> json <| ["opentok", "token"]
  }
}

extension LiveStreamEvent.User: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.User> {
    return curry(LiveStreamEvent.User.init)
      <^> json <| "is_subscribed"
  }
}

// FIXME: Add to `Models/Templates/LiveStreamEventTemplates.swift` and maybe for some of the other models too
extension LiveStreamEvent {
  internal static let template = LiveStreamEvent(
    id: 123,
    stream: Stream(
      name: "Test LiveStreamEvent",
      description: "Test LiveStreamEvent",
      hlsUrl: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
      liveNow: false,
      startDate: NSDate(),
      backgroundImageUrl: "",
      maxOpenTokViewers: 300,
      webUrl: "",
      projectWebUrl: "",
      projectName: "Test Project",
      isRtmp: false,
      isScale: false,
      hasReplay: false,
      replayUrl: nil
    ),
    creator: Creator(
      name: "Creator Name",
      avatar: "https://www.kickstarter.com/creator-avatar.jpg"
    ),
    firebase: Firebase(
      project: "",
      apiKey: "",
      hlsUrlPath: "",
      greenRoomPath: "",
      numberPeopleWatchingPath: "",
      scaleNumberPeopleWatchingPath: "",
      chatPath: ""
    ),
    openTok: OpenTok(
      appId: "123",
      sessionId: "123",
      token: "123"
    ),
    user: User(isSubscribed: false)
  )
}

private let dateFormatter: NSDateFormatter = {
  let dateFormatter = NSDateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  return dateFormatter
}()

private func toDate(dateString: String) -> Decoded<NSDate> {

  guard let date = dateFormatter.dateFromString(dateString) else {
    return .Failure(DecodeError.Custom("Unable to parse date format"))
  }

  return .Success(date)
}
