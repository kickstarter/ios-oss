import Foundation

extension Backing {
  /**
   Returns a minimal `Backing` from a `GraphBacking`
   */
  static func backing(from graphBacking: GraphBacking) -> Backing? {
    guard
      let id = decompose(id: graphBacking.id),
      let backerId = graphBacking.backer.map(\.uid).flatMap(Int.init),
      let projectCountry = graphBacking.project?.country?.code,
      let projectId = graphBacking.project?.pid,
      let backingStatus = backingStatus(from: graphBacking),
      let user = graphBacking.backer
    else { return nil }

    let reward = backingReward(from: graphBacking, projectId: projectId)
    let backer = User.user(from: user)

    return Backing(
      addOns: backingAddOns(from: graphBacking, projectId: projectId),
      amount: graphBacking.amount.amount,
      backer: backer,
      backerId: backerId,
      backerCompleted: graphBacking.backerCompleted,
      bonusAmount: graphBacking.bonusAmount.amount,
      cancelable: graphBacking.cancelable,
      id: id,
      locationId: graphBacking.location.map(\.id).flatMap(decompose(id:)),
      locationName: graphBacking.location?.name,
      paymentSource: backingPaymentSource(from: graphBacking),
      pledgedAt: graphBacking.pledgedOn ?? 0,
      projectCountry: projectCountry,
      projectId: projectId,
      reward: reward,
      rewardId: reward?.id,
      sequence: graphBacking.sequence ?? 0,
      shippingAmount: graphBacking.shippingAmount.map(\.amount).flatMap(Int.init),
      status: backingStatus
    )
  }
}

private func backingAddOns(from graphBacking: GraphBacking, projectId: Int) -> [Reward]? {
  return graphBacking.addOns?.nodes.compactMap { addOn in Reward.reward(from: addOn, projectId: projectId) }
}

private func backingStatus(from graphBacking: GraphBacking) -> Backing.Status? {
  return Backing.Status(rawValue: graphBacking.status.rawValue)
}

private func backingReward(from graphBacking: GraphBacking, projectId: Int) -> Reward? {
  guard let graphReward = graphBacking.reward else { return .noReward }

  return Reward.reward(from: graphReward, projectId: projectId)
}

private func backingPaymentSource(from graphBacking: GraphBacking) -> Backing.PaymentSource? {
  guard let creditCard = graphBacking.creditCard else { return nil }

  return Backing.PaymentSource(
    expirationDate: creditCard.expirationDate,
    id: creditCard.id,
    lastFour: creditCard.lastFour,
    paymentType: creditCard.paymentType,
    state: creditCard.state,
    type: creditCard.type
  )
}
