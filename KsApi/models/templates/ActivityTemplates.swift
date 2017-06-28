import Foundation

extension Activity {
  internal static let template = Activity(
    category: .launch,
    comment: nil,
    createdAt: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970,
    id: 1,
    memberData: Activity.MemberData(
      amount: nil,
      backing: nil,
      oldAmount: nil,
      oldRewardId: nil,
      newAmount: nil,
      newRewardId: nil,
      rewardId: nil
    ),
    project: .template,
    update: nil,
    user: .template
  )
}
