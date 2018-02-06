import Argo
import Curry
import Runes

public struct PushEnvelope {
  public let activity: Activity?
  public let aps: ApsEnvelope
  public let forCreator: Bool?
  public let liveStream: LiveStream?
  public let message: Message?
  public let project: Project?
  public let survey: Survey?
  public let update: Update?

  public struct Activity {
    public let category: KsApi.Activity.Category
    public let commentId: Int?
    public let id: Int
    public let projectId: Int?
    public let projectPhoto: String?
    public let updateId: Int?
    public let userPhoto: String?
  }

  public struct ApsEnvelope {
    public let alert: String
  }

  public struct LiveStream {
    public let id: Int
  }

  public struct Message {
    public let messageThreadId: Int
    public let projectId: Int
  }

  public struct Project {
    public let id: Int
    public let photo: String?
  }

  public struct Survey {
    public let id: Int
    public let projectId: Int
  }

  public struct Update {
    public let id: Int
    public let projectId: Int
  }
}

extension PushEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<PushEnvelope> {

    let update: Decoded<Update> = json <| "update" <|> json <| "post"
    let optionalUpdate: Decoded<Update?> = update.map(Optional.some) <|> .success(nil)

    let tmp = curry(PushEnvelope.init)
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
    let tmp = curry(PushEnvelope.Activity.init)
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
