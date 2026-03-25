import ApolloTestSupport
import Foundation
import GraphAPI
import GraphAPITestMocks
import KsApi

extension GraphAPI.FetchPledgedProjectsQuery {
  public static func fakeData(
    cursors: ClosedRange<Int>? = 1...3,
    hasNextPage: Bool = false
  ) throws -> GraphAPI.FetchPledgedProjectsQuery.Data {
    let edges = cursors?.map { self.mockEdge(cursor: $0) }

    let pageInfo = Mock<PageInfo>()
    pageInfo.hasNextPage = hasNextPage
    pageInfo.hasPreviousPage = false
    pageInfo.endCursor = hasNextPage ? "\(cursors?.upperBound ?? 0)" : nil
    pageInfo.startCursor = "1"

    let pledges = Mock<GraphAPITestMocks.PledgedProjectsOverviewPledgesConnection>()
    pledges.totalCount = edges?.count ?? 0
    pledges.pageInfo = pageInfo
    pledges.edges = edges

    let pledgeProjectsOverview = Mock<GraphAPITestMocks.PledgeProjectsOverview>()
    pledgeProjectsOverview.pledges = pledges

    let query = Mock<GraphAPITestMocks.Query>()
    query.pledgeProjectsOverview = pledgeProjectsOverview

    return GraphAPI.FetchPledgedProjectsQuery.Data.from(query)
  }

  public static func mockEdge(
    cursor: Int = 1,
    addressMock: Mock<GraphAPITestMocks.Address>? = nil,
    projectName: String = UUID().uuidString
  ) -> Mock<GraphAPITestMocks.PledgeProjectOverviewItemEdge> {
    let amount = Mock<GraphAPITestMocks.Money>()
    amount.amount = "1"
    amount.currency = .case(.usd)
    amount.symbol = "$"

    let creator = Mock<GraphAPITestMocks.User>(name: "fakeCreator")

    let project = ProjectCardFragment.mockProject(id: cursor)
    project.creator = creator

    let backing = Mock<GraphAPITestMocks.Backing>()
    backing.id = "\(encodeToBase64("Backing-43"))"
    backing.project = project
    backing.project?.name = projectName
    backing.backingDetailsPageRoute = "fake-backings-route"
    backing.backerCompleted = false
    backing.amount = amount
    backing.deliveryAddress = addressMock

    let pledgeProjectOverviewItem = Mock<GraphAPITestMocks.PledgeProjectOverviewItem>()
    pledgeProjectOverviewItem.tierType = "Tier1PaymentFailed"
    pledgeProjectOverviewItem.showShippingAddress = addressMock.isSome
    pledgeProjectOverviewItem.showEditAddressAction = false
    pledgeProjectOverviewItem.showRewardReceivedToggle = false
    pledgeProjectOverviewItem.flags = []
    pledgeProjectOverviewItem.backing = backing

    return Mock<GraphAPITestMocks.PledgeProjectOverviewItemEdge>.init(
      cursor: "\(cursor)",
      node: pledgeProjectOverviewItem
    )
  }
}
