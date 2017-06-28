import Prelude

extension Project.Personalization {
  public enum lens {
    public static let backing = Lens<Project.Personalization, Backing?>(
      view: { $0.backing },
      set: { Project.Personalization(backing: $0, friends: $1.friends, isBacking: $1.isBacking,
        isStarred: $1.isStarred) }
    )

    public static let friends = Lens<Project.Personalization, [User]?>(
      view: { $0.friends },
      set: { Project.Personalization(backing: $1.backing, friends: $0, isBacking: $1.isBacking,
        isStarred: $1.isStarred) }
    )

    public static let isBacking = Lens<Project.Personalization, Bool?>(
      view: { $0.isBacking },
      set: { Project.Personalization(backing: $1.backing, friends: $1.friends, isBacking: $0,
        isStarred: $1.isStarred) }
    )

    public static let isStarred = Lens<Project.Personalization, Bool?>(
      view: { $0.isStarred },
      set: { Project.Personalization(backing: $1.backing, friends: $1.friends, isBacking: $1.isBacking,
        isStarred: $0) }
    )
  }
}
