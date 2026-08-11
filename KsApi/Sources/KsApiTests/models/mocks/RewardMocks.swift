import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks

extension GraphAPITestMocks.Reward {
  static var mock: Mock<GraphAPITestMocks.Reward> {
    let mockReward = Mock<GraphAPITestMocks.Reward>()

    let mockAmount = Mock<GraphAPITestMocks.Money>()
    mockAmount.amount = "1.0"
    mockAmount.currency = .case(.eur)

    mockReward.id = "UmV3YXJkLTE="
    mockReward.project = Mock<GraphAPITestMocks.Project>()
    mockReward.project?.id = "UHJvamVjdC0x"
    mockReward.allowedAddons = Mock<GraphAPITestMocks.RewardConnection>()
    mockReward.allowedAddons?.pageInfo = Mock<GraphAPITestMocks.PageInfo>()
    mockReward.allowedAddons?.pageInfo?.startCursor = "foo"
    mockReward.convertedAmount = mockAmount
    mockReward.featured = false
    mockReward.latePledgeAmount = mockAmount
    mockReward.amount = mockAmount
    mockReward.pledgeAmount = mockAmount
    mockReward.postCampaignPledgingEnabled = false
    mockReward.available = true
    mockReward.audienceData = Mock<GraphAPITestMocks.ResourceAudience>()
    mockReward.audienceData?.secret = false

    return mockReward
  }
}
