import Foundation
import Prelude

extension Update {
  public enum lens {
    public static let body = Lens<Update, String?>(
      view: { $0.body },
      set: { Update(
        body: $0, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let commentsCount = Lens<Update, Int?>(
      view: { $0.commentsCount },
      set: { Update(
        body: $1.body, commentsCount: $0, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let id = Lens<Update, Int>(
      view: { $0.id },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $0,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let likesCount = Lens<Update, Int?>(
      view: { $0.likesCount },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $0, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let projectId = Lens<Update, Int>(
      view: { $0.projectId },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $0,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let publishedAt = Lens<Update, TimeInterval?>(
      view: { $0.publishedAt },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $0, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let sequence = Lens<Update, Int>(
      view: { $0.sequence },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $0, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let title = Lens<Update, String>(
      view: { $0.title },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $0, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let user = Lens<Update, User?>(
      view: { $0.user },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $0,
        visible: $1.visible
      ) }
    )

    public static let isPublic = Lens<Update, Bool>(
      view: { $0.isPublic },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $0, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $1.urls, user: $1.user,
        visible: $1.visible
      ) }
    )

    public static let urls = Lens<Update, Update.UrlsEnvelope>(
      view: { $0.urls },
      set: { Update(
        body: $1.body, commentsCount: $1.commentsCount, hasLiked: $1.hasLiked, id: $1.id,
        isPublic: $1.isPublic, likesCount: $1.likesCount, projectId: $1.projectId,
        publishedAt: $1.publishedAt, sequence: $1.sequence, title: $1.title, urls: $0, user: $1.user,
        visible: $1.visible
      ) }
    )
  }
}

extension Update.UrlsEnvelope {
  public enum lens {
    public static let web = Lens<Update.UrlsEnvelope, Update.UrlsEnvelope.WebEnvelope>(
      view: { $0.web },
      set: { part, _ in .init(web: part) }
    )
  }
}

extension Update.UrlsEnvelope.WebEnvelope {
  public enum lens {
    public static let update = Lens<Update.UrlsEnvelope.WebEnvelope, String>(
      view: { $0.update },
      set: { part, _ in .init(update: part) }
    )
  }
}

extension Lens where Whole == Update, Part == Update.UrlsEnvelope {
  public var web: Lens<Whole, Update.UrlsEnvelope.WebEnvelope> {
    return Whole.lens.urls .. Part.lens.web
  }
}

extension Lens where Whole == Update, Part == Update.UrlsEnvelope.WebEnvelope {
  public var update: Lens<Whole, String> {
    return Whole.lens.urls.web .. Part.lens.update
  }
}
