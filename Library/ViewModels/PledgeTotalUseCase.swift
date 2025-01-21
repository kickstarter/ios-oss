import ReactiveSwift

public final class PledgeTotalUseCase {
  init(initialData: Signal<PledgeViewData, Never>) {
    let context = initialData.map(\.context)
    let rewards = initialData.map(\.rewards)
    let baseReward = initialData.map(\.rewards).map(\.first).skipNil()
    let project = initialData.map(\.project)
    let selectedShippingRule = initialData.map(\.selectedShippingRule)
    let selectedQuantities = initialData.map(\.selectedQuantities)
    let refTag = initialData.map(\.refTag)
    let bonusAmount = initialData.map { $0.bonusSupport ?? 0.0 }
    let backing = project.map { $0.personalization.backing }.skipNil()

    let calculatedShippingTotal = Signal.combineLatest(
      selectedShippingRule.skipNil(),
      rewards,
      selectedQuantities
    )
    .map(calculateShippingTotal)

    self.allRewardsShippingTotal = Signal.merge(
      selectedShippingRule.filter { $0 == nil }.mapConst(0.0),
      calculatedShippingTotal
    )

    self.allRewardsTotal = Signal.combineLatest(
      rewards,
      selectedQuantities
    )
    .map(calculateAllRewardsTotal)

    /*
     * For a regular reward this includes the bonus support amount,
     * the total of all rewards and their respective shipping costs.
     * For No Reward this is only the pledge amount.
     * Never calculate the pledge total in a fix payment method context.
     */

    let calculatedPledgeTotal = Signal.combineLatest(
      bonusAmount,
      self.allRewardsShippingTotal,
      self.allRewardsTotal
    )
    .map(calculatePledgeTotal)
    .filterWhenLatestFrom(context, satisfies: { $0 != .fixPaymentMethod })

    self.pledgeTotal = Signal.merge(
      backing.map(\.amount),
      calculatedPledgeTotal
    )
  }

  // Outputs
  let pledgeTotal: Signal<Double, Never>
  let allRewardsShippingTotal: Signal<Double, Never>
  let allRewardsTotal: Signal<Double, Never>
}
