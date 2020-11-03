import Curry

public struct PushEnvelope {
  public let activity: Activity?
  public let aps: ApsEnvelope
  public let erroredPledge: ErroredPledge?
  public let forCreator: Bool?
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

  public struct ErroredPledge {
    public let projectId: Int
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

extension PushEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case activity
    case aps
    case erroredPledge = "errored_pledge"
    case forCreator = "for_creator"
    case message
    case project
    case survey
    case update
    case post
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.activity = try values.decodeIfPresent(Activity.self, forKey: .activity)
    self.aps = try values.decode(ApsEnvelope.self, forKey: .aps)
    self.erroredPledge = try values.decodeIfPresent(ErroredPledge.self, forKey: .erroredPledge)
    self.forCreator = try values.decodeIfPresent(Bool.self, forKey: .forCreator)
    self.message = try values.decodeIfPresent(Message.self, forKey: .message)
    self.project = try values.decodeIfPresent(Project.self, forKey: .project)
    self.survey = try values.decodeIfPresent(Survey.self, forKey: .survey)
    if values.contains(.update) {
      self.update = try values.decodeIfPresent(Update.self, forKey: .update)
    } else {
      self.update = try values.decodeIfPresent(Update.self, forKey: .post)
    }
  }
}

extension PushEnvelope.Activity: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case category
    case commentId = "comment_id"
    case id
    case projectId = "project_id"
    case projectPhoto = "project_photo"
    case updateId = "update_id"
    case userPhoto = "user_photo"
  }
}

extension PushEnvelope.ApsEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case alert
  }
}

extension PushEnvelope.ErroredPledge: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case projectId = "project_id"
  }
}

extension PushEnvelope.Message: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case messageThreadId = "message_thread_id"
    case projectId = "project_id"
  }
}

extension PushEnvelope.Project: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case photo
  }
}

extension PushEnvelope.Survey: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case projectId = "project_id"
  }
}

extension PushEnvelope.Update: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case projectId = "project_id"
  }
}
