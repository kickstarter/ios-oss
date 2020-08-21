import Foundation

extension GraphProject {
  internal static let template = GraphProject(
    actions: .init(displayConvertAmount: false),
    addOns: .init(nodes: [.template, .template]),
    backersCount: 5,
    category: GraphCategory(id: "VXNlci0xNTQ2MjM2ODI=", name: "My Category", parentCategory: nil),
    country: .init(code: "CA", name: "Canada"),
    creator: .template,
    currency: "USD",
    deadlineAt: 12_342_342_343,
    description: "Project description",
    finalCollectionDate: "2020-04-08T15:15:05Z",
    fxRate: 1,
    goal: Money(amount: 150, currency: .usd, symbol: "$"),
    image: .init(id: "44554", url: "http://www.kickstarter.com/my/picture.jpg"),
    isProjectWeLove: false,
    launchedAt: 2_342_342_342,
    location: .template,
    name: "Cool project",
    pid: 1,
    pledged: Money(amount: 150, currency: .usd, symbol: "$"),
    prelaunchActivated: false,
    rewards: .init(nodes: [.template]),
    slug: "/cool-project",
    state: .live,
    stateChangedAt: 23_452_223,
    url: "http://www.kickstarter.com/cool/project",
    usdExchangeRate: 1
  )
}
