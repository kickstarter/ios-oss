import Prelude

extension StarEnvelope {
  public enum lens {
    public static let user = Lens<StarEnvelope, User>(
      view: { $0.user },
      set: { StarEnvelope(user: $0, project: $1.project) }
    )

    public static let project = Lens<StarEnvelope, Project>(
      view: { $0.project },
      set: { StarEnvelope(user: $1.user, project: $0) }
    )
  }
}
