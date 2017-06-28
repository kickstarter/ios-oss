import Prelude

extension Activity {
  public enum lens {
    public static let category = Lens<Activity, Activity.Category>(
      view: { $0.category },
      set: { Activity(category: $0, comment: $1.comment, createdAt: $1.createdAt, id: $1.id,
        memberData: $1.memberData, project: $1.project, update: $1.update, user: $1.user) }
    )

    public static let comment = Lens<Activity, Comment?>(
      view: { $0.comment },
      set: { Activity(category: $1.category, comment: $0, createdAt: $1.createdAt, id: $1.id,
        memberData: $1.memberData, project: $1.project, update: $1.update, user: $1.user) }
    )

    public static let createdAt = Lens<Activity, TimeInterval>(
      view: { $0.createdAt },
      set: { Activity(category: $1.category, comment: $1.comment, createdAt: $0, id: $1.id,
        memberData: $1.memberData, project: $1.project, update: $1.update, user: $1.user) }
    )

    public static let id = Lens<Activity, Int>(
      view: { $0.id },
      set: { Activity(category: $1.category, comment: $1.comment, createdAt: $1.createdAt, id: $0,
        memberData: $1.memberData, project: $1.project, update: $1.update, user: $1.user) }
    )

    public static let memberData = Lens<Activity, MemberData>(
      view: { $0.memberData },
      set: { Activity(category: $1.category, comment: $1.comment, createdAt: $1.createdAt, id: $1.id,
        memberData: $0, project: $1.project, update: $1.update, user: $1.user) }
    )

    public static let project = Lens<Activity, Project?>(
      view: { $0.project },
      set: { Activity(category: $1.category, comment: $1.comment, createdAt: $1.createdAt, id: $1.id,
        memberData: $1.memberData, project: $0, update: $1.update, user: $1.user) }
    )

    public static let update = Lens<Activity, Update?>(
      view: { $0.update },
      set: { Activity(category: $1.category, comment: $1.comment, createdAt: $1.createdAt, id: $1.id,
        memberData: $1.memberData, project: $1.project, update: $0, user: $1.user) }
    )

    public static let user = Lens<Activity, User?>(
      view: { $0.user },
      set: { Activity(category: $1.category, comment: $1.comment, createdAt: $1.createdAt, id: $1.id,
        memberData: $1.memberData, project: $1.project, update: $1.update, user: $0) }
    )
  }
}

extension Lens where Whole == Activity, Part == Activity.MemberData {
  public var amount: Lens<Activity, Int?> {
    return Activity.lens.memberData..Activity.MemberData.lens.amount
  }

  public var backing: Lens<Activity, Backing?> {
    return Activity.lens.memberData..Activity.MemberData.lens.backing
  }

  public var oldAmount: Lens<Activity, Int?> {
    return Activity.lens.memberData..Activity.MemberData.lens.oldAmount
  }

  public var oldRewardId: Lens<Activity, Int?> {
    return Activity.lens.memberData..Activity.MemberData.lens.oldRewardId
  }

  public var newAmount: Lens<Activity, Int?> {
    return Activity.lens.memberData..Activity.MemberData.lens.newAmount
  }

  public var newRewardId: Lens<Activity, Int?> {
    return Activity.lens.memberData..Activity.MemberData.lens.newRewardId
  }

  public var rewardId: Lens<Activity, Int?> {
    return Activity.lens.memberData..Activity.MemberData.lens.rewardId
  }
}
