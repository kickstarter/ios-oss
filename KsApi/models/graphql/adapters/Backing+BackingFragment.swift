import Prelude
import ReactiveSwift

extension Backing {
  /**
   Returns a minimal `Backing` from a `BackingFragment`
   */
  static func backing(
    from backingFragment: GraphAPI.BackingFragment,
    addOns: [Reward]? = nil
  ) -> Backing? {
    guard
      let id = decompose(id: backingFragment.id),
      let backerIdString = backingFragment.backer?.fragments.userFragment.uid,
      let backerId = Int(backerIdString),
      let projectCountry = backingFragment.project?.fragments.projectFragment.country.fragments
      .countryFragment.code,
      let projectId = backingFragment.project?.fragments.projectFragment.pid,
      let backingStatus = backingStatus(from: backingFragment),
      let user = backingFragment.backer?.fragments.userFragment
    else { return nil }

    let reward = backingReward(from: backingFragment)
    let backer = User.user(from: user)
    var locationId: Int?
    if let locationGraphId = backingFragment.location?.fragments.locationFragment.id {
      locationId = decompose(id: locationGraphId)
    }

    return Backing(
      addOns: addOns,
      amount: backingFragment.amount.fragments.moneyFragment.amount.flatMap(Double.init) ?? 0,
      backer: backer,
      backerId: backerId,
      backerCompleted: backingFragment.backerCompleted,
      bonusAmount: backingFragment.bonusAmount.fragments.moneyFragment.amount.flatMap(Double.init) ?? 0,
      cancelable: backingFragment.cancelable,
      id: id,
      locationId: locationId,
      locationName: backingFragment.location?.fragments.locationFragment.name,
      paymentSource: backingPaymentSource(from: backingFragment),
      pledgedAt: backingFragment.pledgedOn.flatMap(Double.init) ?? 0,
      projectCountry: projectCountry.rawValue,
      projectId: projectId,
      reward: reward,
      rewardId: reward?.id,
      sequence: backingFragment.sequence ?? 0,
      shippingAmount: backingFragment.shippingAmount?.fragments.moneyFragment.amount.flatMap(Double.init),
      status: backingStatus
    )
  }
}

private func backingStatus(from backingFragment: GraphAPI.BackingFragment) -> Backing.Status? {
  return Backing.Status(rawValue: backingFragment.status.rawValue)
}

private func backingReward(from backingFragment: GraphAPI.BackingFragment) -> Reward? {
  guard let reward = backingFragment.reward?.fragments.rewardFragment else {
    let projectMinimumPledgeAmount: Int = backingFragment.project?.fragments.projectFragment.minPledge ?? 1
    let projectFXRate: Double = backingFragment.project?.fragments.projectFragment.fxRate ?? 1.0

    let convertedMinimumAmount = projectFXRate * Double(projectMinimumPledgeAmount)

    let emptyReward = Reward.noReward
      |> Reward.lens.minimum .~ Double(projectMinimumPledgeAmount)
      |> Reward.lens.convertedMinimum .~ convertedMinimumAmount

    return emptyReward
  }

  return Reward.reward(from: reward)
}

private func backingPaymentSource(from backingFragment: GraphAPI.BackingFragment) -> Backing.PaymentSource? {
  guard
    let creditCard = backingFragment.creditCard?.fragments.creditCardFragment.asCreditCard,
    let paymentType = PaymentType(rawValue: creditCard.paymentType.rawValue),
    let type = CreditCardType(rawValue: creditCard.type.rawValue)
  else { return nil }

  return Backing.PaymentSource(
    expirationDate: creditCard.expirationDate,
    id: creditCard.id,
    lastFour: creditCard.lastFour,
    paymentType: paymentType,
    state: creditCard.state.rawValue,
    type: type
  )
}
