import Argo
import Curry
import Runes

public struct LiveStreamEvent: Equatable {
  public let creator: Creator
  public let firebase: Firebase
  public let id: Int
  public let openTok: OpenTok
  public let stream: Stream
  public let user: User

  public struct Stream {
    public let backgroundImageUrl: String
    public let description: String
    public let hasReplay: Bool
    public let hlsUrl: String // FIXME: ask justin if this is guaranteed?
    public let isRtmp: Bool
    public let isScale: Bool
    public let liveNow: Bool
    public let maxOpenTokViewers: Int
    public let name: String
    public let projectWebUrl: String
    public let projectName: String
    public let replayUrl: String?
    public let startDate: Date
    public let webUrl: String

    // Useful for safeguarding against getting a `hasReplay == true` yet the `replayUrl` is `nil`.
    public var definitelyHasReplay: Bool {
      return self.hasReplay && self.replayUrl != nil
    }
  }

  public struct Creator {
    public let avatar: String
    public let name: String
  }

  public struct Firebase {
    public let apiKey: String
    public let chatPath: String
    public let greenRoomPath: String
    public let hlsUrlPath: String
    public let numberPeopleWatchingPath: String
    public let project: String
    public let scaleNumberPeopleWatchingPath: String
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
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEvent> {
    let create = curry(LiveStreamEvent.init)
    return create
      <^> json <| "creator"
      <*> json <| "firebase"
      <*> json <| "id"
      <*> json <| "opentok"
      <*> json <| "stream"
      <*> (json <| "user" <|> .success(User(isSubscribed: false)))
  }
}

extension LiveStreamEvent.Stream: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEvent.Stream> {
    let create = curry(LiveStreamEvent.Stream.init)
    let tmp1 = create
      <^> json <| "background_image_url"
      <*> json <| "description"
      <*> json <| "has_replay"
      <*> json <| "hls_url"
      <*> json <| "is_rtmp"
      <*> json <| "is_scale"

    let tmp2 = tmp1
      <*> json <| "live_now"
      <*> json <| "max_opentok_viewers"
      <*> json <| "name"
      <*> json <| "project_web_url"
      <*> json <| "project_name"
      <*> json <|? "replay_url"
      <*> (json <| "start_date" >>- toDate)
      <*> json <| "web_url"

    return tmp2
  }
}

extension LiveStreamEvent.Creator: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEvent.Creator> {
    return curry(LiveStreamEvent.Creator.init)
      <^> json <| "creator_avatar"
      <*> json <| "creator_name"
  }
}

extension LiveStreamEvent.Firebase: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEvent.Firebase> {
    return curry(LiveStreamEvent.Firebase.init)
      <^> json <| "firebase_api_key"
      <*> json <| "chat_path"
      <*> json <| "green_room_path"
      <*> json <| "hls_url_path"
      <*> json <| "number_people_watching_path"
      <*> json <| "firebase_project"
      <*> json <| "scale_number_people_watching_path"
  }
}

extension LiveStreamEvent.OpenTok: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEvent.OpenTok> {
    return curry(LiveStreamEvent.OpenTok.init)
      <^> json <| "app"
      <*> json <| "session"
      <*> json <| "token"
  }
}

extension LiveStreamEvent.User: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEvent.User> {
    return curry(LiveStreamEvent.User.init)
      <^> json <| "is_subscribed"
  }
}

private let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  return dateFormatter
}()

private func toDate(dateString: String) -> Decoded<Date> {

  guard let date = dateFormatter.date(from: dateString) else {
    return .failure(DecodeError.custom("Unable to parse date format"))
  }

  return .success(date)
}
