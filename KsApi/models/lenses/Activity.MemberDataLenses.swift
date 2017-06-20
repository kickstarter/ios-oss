import Prelude

extension Activity.MemberData {
  public enum lens {
    public static let amount = Lens<Activity.MemberData, Int?>(
      view: { $0.amount },
      set: { Activity.MemberData(amount: $0, backing: $1.backing, oldAmount: $1.oldAmount,
        oldRewardId: $1.oldRewardId, newAmount: $1.newAmount, newRewardId: $1.newRewardId,
        rewardId: $1.rewardId) }
    )

    public static let backing = Lens<Activity.MemberData, Backing?>(
      view: { $0.backing },
      set: { Activity.MemberData(amount: $1.amount, backing: $0, oldAmount: $1.oldAmount,
        oldRewardId: $1.oldRewardId, newAmount: $1.newAmount, newRewardId: $1.newRewardId,
        rewardId: $1.rewardId) }
    )

    public static let oldAmount = Lens<Activity.MemberData, Int?>(
      view: { $0.oldAmount },
      set: { Activity.MemberData(amount: $1.amount, backing: $1.backing, oldAmount: $0,
        oldRewardId: $1.oldRewardId, newAmount: $1.newAmount, newRewardId: $1.newRewardId,
        rewardId: $1.rewardId) }
    )

    public static let oldRewardId = Lens<Activity.MemberData, Int?>(
      view: { $0.oldRewardId },
      set: { Activity.MemberData(amount: $1.amount, backing: $1.backing, oldAmount: $1.oldAmount,
        oldRewardId: $0, newAmount: $1.newAmount, newRewardId: $1.newRewardId,
        rewardId: $1.rewardId) }
    )

    public static let newAmount = Lens<Activity.MemberData, Int?>(
      view: { $0.newAmount },
      set: { Activity.MemberData(amount: $1.amount, backing: $1.backing, oldAmount: $1.oldAmount,
        oldRewardId: $1.oldRewardId, newAmount: $0, newRewardId: $1.newRewardId,
        rewardId: $1.rewardId) }
    )

    public static let newRewardId = Lens<Activity.MemberData, Int?>(
      view: { $0.newRewardId },
      set: { Activity.MemberData(amount: $1.amount, backing: $1.backing, oldAmount: $1.oldAmount,
        oldRewardId: $1.oldRewardId, newAmount: $1.newAmount, newRewardId: $0,
        rewardId: $1.rewardId) }
    )

    public static let rewardId = Lens<Activity.MemberData, Int?>(
      view: { $0.rewardId },
      set: { Activity.MemberData(amount: $1.amount, backing: $1.backing, oldAmount: $1.oldAmount,
        oldRewardId: $1.oldRewardId, newAmount: $1.newRewardId, newRewardId: $1.newRewardId,
        rewardId: $0) }
    )
  }
}
