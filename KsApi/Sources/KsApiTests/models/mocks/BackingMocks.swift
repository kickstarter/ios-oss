import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi

extension GraphAPITestMocks.Backing {
  static var mock: Mock<GraphAPITestMocks.Backing> {
    let backing = Mock<GraphAPITestMocks.Backing>(id: "YmFja2luZy0x")
    backing.amount = Mock<GraphAPITestMocks.Money>()
    backing.backer = GraphAPITestMocks.User.mock
    backing.status = GraphQLEnum(.pledged)
    backing.backerCompleted = true
    backing.backingDetailsPageRoute = "https://ksr.com/backing/details"
    backing.cancelable = true
    backing.isLatePledge = true
    backing.project = GraphAPITestMocks.Project.mock
    backing.project?.posts = Mock<GraphAPITestMocks.PostConnection>(totalCount: 0)
    backing.paymentIncrements = []
    backing.bonusAmount = Mock<GraphAPITestMocks.Money>()
    backing.bonusAmount?.amount = "50"
    backing.bonusAmount?.currency = .case(.usd)
    backing.bonusAmount?.symbol = "$"
    backing.shippingAmount = Mock<GraphAPITestMocks.Money>()
    backing.shippingAmount?.amount = "1"
    backing.rewardsAmount = Mock<GraphAPITestMocks.Money>()
    backing.rewardsAmount?.amount = "10"
    backing.rewardsAmount?.currency = .case(.usd)
    backing.rewardsAmount?.symbol = "$"
    return backing
  }
}
