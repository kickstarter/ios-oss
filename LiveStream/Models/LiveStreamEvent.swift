import Argo
import Curry

public struct LiveStreamEvent: Equatable {
  public let creator: Creator
  public let firebase: Firebase
  public let id: Int
  public let openTok: OpenTok
  public let stream: Stream
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
      <^> json <| "creator"
      <*> json <| "firebase"
      <*> json <| "id"
      <*> json <| "opentok"
      <*> json <| "stream"
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
      <^> json <| "creator_name"
      <*> json <| "creator_avatar"
  }
}

extension LiveStreamEvent.Firebase: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.Firebase> {
    return curry(LiveStreamEvent.Firebase.init)
      <^> json <| "firebase_project"
      <*> json <| "firebase_api_key"
      <*> json <| "hls_url_path"
      <*> json <| "green_room_path"
      <*> json <| "number_people_watching_path"
      <*> json <| "scale_number_people_watching_path"
      <*> json <| "chat_path"
  }
}

extension LiveStreamEvent.OpenTok: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.OpenTok> {
    return curry(LiveStreamEvent.OpenTok.init)
      <^> json <| "app"
      <*> json <| "session"
      <*> json <| "token"
  }
}

extension LiveStreamEvent.User: Decodable {
  static public func decode(json: JSON) -> Decoded<LiveStreamEvent.User> {
    return curry(LiveStreamEvent.User.init)
      <^> json <| "is_subscribed"
  }
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
