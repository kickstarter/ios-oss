import Prelude

extension GraphBacking {
  static let template = GraphBacking(
    addOns: .template,
    amount: Money(amount: 179.0, currency: .usd, symbol: "$"),
    backer: .template,
    backerCompleted: false,
    bankAccount: BankAccount(bankName: "Best Bank", id: "1123", lastFour: "5555"),
    bonusAmount: Money(amount: 5.0, currency: .usd, symbol: "$"),
    cancelable: true,
    creditCard: .init(
      expirationDate: "2020-01-01",
      id: "556",
      lastFour: "1234",
      paymentType: .creditCard,
      state: "ACTIVE",
      type: .visa
    ),
    errorReason: "Error",
    id: "QmFja2luZy0xMTMzMTQ5ODE=",
    location: .template,
    pledgedOn: 1_587_502_131,
    project: .template,
    reward: .template,
    sequence: 1,
    shippingAmount: Money(amount: 20.0, currency: .usd, symbol: "$"),
    status: .pledged
  )
}

extension GraphBacking {
  internal static let errored = GraphBacking.template
    |> \.status .~ BackingState.errored
    |> \.errorReason .~ "Credit card expired."
    |> \.project .~ .template
}

extension GraphBacking.AddOns {
  static let template = GraphBacking.AddOns(nodes: [.template])
}
