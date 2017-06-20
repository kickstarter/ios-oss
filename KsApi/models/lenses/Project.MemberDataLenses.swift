import Prelude

extension Project.MemberData {
  public enum lens {
    public static let lastUpdatePublishedAt = Lens<Project.MemberData, TimeInterval?>(
      view: { $0.lastUpdatePublishedAt },
      set: { Project.MemberData(lastUpdatePublishedAt: $0, permissions: $1.permissions,
        unreadMessagesCount: $1.unreadMessagesCount, unseenActivityCount: $1.unseenActivityCount) }
    )

    public static let permissions = Lens<Project.MemberData, [Project.MemberData.Permission]>(
      view: { $0.permissions },
      set: { Project.MemberData(lastUpdatePublishedAt: $1.lastUpdatePublishedAt, permissions: $0,
        unreadMessagesCount: $1.unreadMessagesCount, unseenActivityCount: $1.unseenActivityCount) }
    )

    public static let unreadMessagesCount = Lens<Project.MemberData, Int?>(
      view: { $0.unreadMessagesCount },
      set: { Project.MemberData(lastUpdatePublishedAt: $1.lastUpdatePublishedAt, permissions: $1.permissions,
        unreadMessagesCount: $0, unseenActivityCount: $1.unseenActivityCount) }
    )

    public static let unseenActivityCount = Lens<Project.MemberData, Int?>(
      view: { $0.unseenActivityCount },
      set: { Project.MemberData(lastUpdatePublishedAt: $1.lastUpdatePublishedAt, permissions: $1.permissions,
        unreadMessagesCount: $1.unreadMessagesCount, unseenActivityCount: $0) }
    )
  }
}
