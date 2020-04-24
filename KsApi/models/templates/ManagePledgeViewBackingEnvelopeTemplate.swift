extension ManagePledgeViewBackingEnvelope {
  static var template: ManagePledgeViewBackingEnvelope {
    return ManagePledgeViewBackingEnvelope(
      project: .init(id: "123", name: "Project", state: .live),
      backing: .init(
        amount: Money(amount: "179.0", currency: .usd, symbol: "$"),
        backer: Backing.Backer(id: "1234", name: "Backer McGee"),
        bankAccount: nil,
        creditCard: Backing.CreditCard(
          expirationDate: "2020-01-01",
          id: "556",
          lastFour: "1234",
          paymentType: .creditCard,
          type: .visa
        ),
        errorReason: "Error",
        pledgedOn: 1_587_502_131,
        reward: Backing.Reward(
          amount: Money(amount: "159.0", currency: .usd, symbol: "$"),
          backersCount: 55,
          description: "Description",
          estimatedDeliveryOn: "2020-08-01",
          items: [
            .init(id: "432", name: "Item 1"),
            .init(id: "442", name: "Item 2")
          ],
          name: "Reward name"
        ),
        shippingAmount: Money(amount: "20.0", currency: .usd, symbol: "$"),
        status: .pledged
      )
    )
  }
}
