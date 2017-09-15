import Argo
import Curry
import Runes

public struct PushEnvelope {
  public private(set) var activity: Activity?
  public private(set) var aps: ApsEnvelope
  public private(set) var forCreator: Bool?
  public private(set) var liveStream: LiveStream?
  public private(set) var message: Message?
  public private(set) var project: Project?
  public private(set) var survey: Survey?
  public private(set) var update: Update?

  public struct Activity {
    public private(set) var category: KsApi.Activity.Category
    public private(set) var commentId: Int?
    public private(set) var id: Int
    public private(set) var projectId: Int?
    public private(set) var projectPhoto: String?
    public private(set) var updateId: Int?
    public private(set) var userPhoto: String?
  }

  public struct ApsEnvelope {
    public private(set) var alert: String
  }

  public struct LiveStream {
    public private(set) var id: Int
  }

  public struct Message {
    public private(set) var messageThreadId: Int
    public private(set) var projectId: Int
  }

  public struct Project {
    public private(set) var id: Int
    public private(set) var photo: String?
  }

  public struct Survey {
    public private(set) var id: Int
    public private(set) var projectId: Int
  }

  public struct Update {
    public private(set) var id: Int
    public private(set) var projectId: Int
  }
}

extension PushEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope> {
    let create = curry(PushEnvelope.init)

    let update: Decoded<Update> = json <| "update" <|> json <| "post"
    let optionalUpdate: Decoded<Update?> = update.map(Optional.some) <|> .success(nil)

    let tmp = create
      <^> json <|? "activity"
      <*> json <| "aps"
      <*> json <|? "for_creator"
      <*> json <|? "live_stream"
    return tmp
      <*> json <|? "message"
      <*> json <|? "project"
      <*> json <|? "survey"
      <*> optionalUpdate
  }
}

extension PushEnvelope.Activity: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.Activity> {
    let create = curry(PushEnvelope.Activity.init)
    let tmp = create
      <^> json <| "category"
      <*> json <|? "comment_id"
      <*> json <| "id"
      <*> json <|? "project_id"
    return tmp
      <*> json <|? "project_photo"
      <*> json <|? "update_id"
      <*> json <|? "user_photo"
  }
}

extension PushEnvelope.ApsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.ApsEnvelope> {
    return curry(PushEnvelope.ApsEnvelope.init)
      <^> json <| "alert"
  }
}

extension PushEnvelope.LiveStream: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.LiveStream> {
    return curry(PushEnvelope.LiveStream.init)
      <^> json <| "id"
  }
}

extension PushEnvelope.Message: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.Message> {
    return curry(PushEnvelope.Message.init)
      <^> json <| "message_thread_id"
      <*> json <| "project_id"
  }
}

extension PushEnvelope.Project: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.Project> {
    return curry(PushEnvelope.Project.init)
      <^> json <| "id"
      <*> json <|? "photo"
  }
}

extension PushEnvelope.Survey: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.Survey> {
    return curry(PushEnvelope.Survey.init)
      <^> json <| "id"
      <*> json <| "project_id"
  }
}

extension PushEnvelope.Update: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope.Update> {
    return curry(PushEnvelope.Update.init)
      <^> json <| "id"
      <*> json <| "project_id"
  }
}
