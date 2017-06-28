import Prelude

extension PushEnvelope {
  public enum lens {
    public static let activity = Lens<PushEnvelope, PushEnvelope.Activity?>(
      view: { $0.activity },
      set: { .init(activity: $0, aps: $1.aps, forCreator: $1.forCreator, liveStream: $1.liveStream,
                   message: $1.message, project: $1.project, survey: $1.survey, update: $1.update) }
    )

    public static let aps = Lens<PushEnvelope, PushEnvelope.ApsEnvelope>(
      view: { $0.aps },
      set: { .init(activity: $1.activity, aps: $0, forCreator: $1.forCreator, liveStream: $1.liveStream,
                   message: $1.message, project: $1.project, survey: $1.survey, update: $1.update) }
    )

    public static let forCreator = Lens<PushEnvelope, Bool?>(
      view: { $0.forCreator },
      set: { .init(activity: $1.activity, aps: $1.aps, forCreator: $0, liveStream: $1.liveStream,
                   message: $1.message, project: $1.project, survey: $1.survey, update: $1.update) }
    )

    public static let liveStream = Lens<PushEnvelope, PushEnvelope.LiveStream?>(
      view: { $0.liveStream },
      set: { .init(activity: $1.activity, aps: $1.aps, forCreator: $1.forCreator, liveStream: $0,
                   message: $1.message, project: $1.project, survey: $1.survey, update: $1.update) }
    )

    public static let message = Lens<PushEnvelope, PushEnvelope.Message?>(
      view: { $0.message },
      set: { .init(activity: $1.activity, aps: $1.aps, forCreator: $1.forCreator, liveStream: $1.liveStream,
                   message: $0, project: $1.project, survey: $1.survey, update: $1.update) }
    )

    public static let project = Lens<PushEnvelope, PushEnvelope.Project?>(
      view: { $0.project },
      set: { .init(activity: $1.activity, aps: $1.aps, forCreator: $1.forCreator, liveStream: $1.liveStream,
                   message: $1.message, project: $0, survey: $1.survey, update: $1.update) }
    )

    public static let survey = Lens<PushEnvelope, PushEnvelope.Survey?>(
      view: { $0.survey },
      set: { .init(activity: $1.activity, aps: $1.aps, forCreator: $1.forCreator, liveStream: $1.liveStream,
                   message: $1.message, project: $1.project, survey: $0, update: $1.update) }
    )

    public static let update = Lens<PushEnvelope, PushEnvelope.Update?>(
      view: { $0.update },
      set: { .init(activity: $1.activity, aps: $1.aps, forCreator: $1.forCreator, liveStream: $1.liveStream,
                   message: $1.message, project: $1.project, survey: $1.survey, update: $0) }
    )
  }
}

extension PushEnvelope.Activity {
  public enum lens {
    public static let category = Lens<PushEnvelope.Activity, KsApi.Activity.Category>(
      view: { $0.category },
      set: { .init(category: $0, commentId: $1.commentId, id: $1.id, projectId: $1.projectId,
        projectPhoto: $1.projectPhoto, updateId: $1.updateId, userPhoto: $1.userPhoto) }
    )

    public static let commentId = Lens<PushEnvelope.Activity, Int?>(
      view: { $0.commentId },
      set: { .init(category: $1.category, commentId: $0, id: $1.id, projectId: $1.projectId,
        projectPhoto: $1.projectPhoto, updateId: $1.updateId, userPhoto: $1.userPhoto) }
    )

    public static let id = Lens<PushEnvelope.Activity, Int>(
      view: { $0.id },
      set: { .init(category: $1.category, commentId: $1.commentId, id: $0, projectId: $1.projectId,
        projectPhoto: $1.projectPhoto, updateId: $1.updateId, userPhoto: $1.userPhoto) }
    )

    public static let projectId = Lens<PushEnvelope.Activity, Int?>(
      view: { $0.projectId },
      set: { .init(category: $1.category, commentId: $1.commentId, id: $1.id, projectId: $0,
        projectPhoto: $1.projectPhoto, updateId: $1.updateId, userPhoto: $1.userPhoto) }
    )

    public static let projectPhoto = Lens<PushEnvelope.Activity, String?>(
      view: { $0.projectPhoto },
      set: { .init(category: $1.category, commentId: $1.commentId, id: $1.id, projectId: $1.projectId,
        projectPhoto: $0, updateId: $1.updateId, userPhoto: $1.userPhoto) }
    )

    public static let updateId = Lens<PushEnvelope.Activity, Int?>(
      view: { $0.updateId },
      set: { .init(category: $1.category, commentId: $1.commentId, id: $1.id, projectId: $1.projectId,
        projectPhoto: $1.projectPhoto, updateId: $0, userPhoto: $1.userPhoto) }
    )

    public static let userPhoto = Lens<PushEnvelope.Activity, String?>(
      view: { $0.userPhoto },
      set: { .init(category: $1.category, commentId: $1.commentId, id: $1.id, projectId: $1.projectId,
        projectPhoto: $1.projectPhoto, updateId: $1.updateId, userPhoto: $0) }
    )
  }
}

extension PushEnvelope.ApsEnvelope {
  public enum lens {
    public static let alert = Lens<PushEnvelope.ApsEnvelope, String>(
      view: { $0.alert },
      set: { alert, _ in .init(alert: alert) }
    )
  }
}

extension PushEnvelope.Message {
  public enum lens {
    public static let messageThreadId = Lens<PushEnvelope.Message, Int>(
      view: { $0.messageThreadId },
      set: { .init(messageThreadId: $0, projectId: $1.projectId) }
    )

    public static let projectId = Lens<PushEnvelope.Message, Int>(
      view: { $0.projectId },
      set: { .init(messageThreadId: $1.messageThreadId, projectId: $0) }
    )
  }
}

extension PushEnvelope.Project {
  public enum lens {
    public static let id = Lens<PushEnvelope.Project, Int>(
      view: { $0.id },
      set: { .init(id: $0, photo: $1.photo) }
    )

    public static let photo = Lens<PushEnvelope.Project, String?>(
      view: { $0.photo },
      set: { .init(id: $1.id, photo: $0) }
    )
  }
}

extension PushEnvelope.Survey {
  public enum lens {
    public static let id = Lens<PushEnvelope.Survey, Int>(
      view: { $0.id },
      set: { .init(id: $0, projectId: $1.projectId) }
    )

    public static let projectId = Lens<PushEnvelope.Survey, Int>(
      view: { $0.projectId },
      set: { .init(id: $1.id, projectId: $0) }
    )
  }
}

extension PushEnvelope.Update {
  public enum lens {
    public static let id = Lens<PushEnvelope.Update, Int>(
      view: { $0.id },
      set: { .init(id: $0, projectId: $1.projectId) }
    )

    public static let projectId = Lens<PushEnvelope.Update, Int>(
      view: { $0.projectId },
      set: { .init(id: $1.id, projectId: $0) }
    )
  }
}
