import Foundation

extension Activity {
  internal static let template = Activity(
    category: .launch,
    comment: nil,
    createdAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970,
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
    trackingNumber: nil,
    trackingUrl: nil,
    update: nil,
    user: .template
  )
}
