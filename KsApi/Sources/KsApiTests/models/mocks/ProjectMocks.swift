import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi

extension GraphAPITestMocks.Project {
  static var mock: Mock<GraphAPITestMocks.Project> {
    let project = Mock<GraphAPITestMocks.Project>()
    project.name = "The project"
    project.country = Mock<GraphAPITestMocks.Country>()
    project.country?.code = GraphQLEnum(.us)
    project.country?.name = "USA"
    project.currency = .case(.usd)
    project.pid = 987
    project.minPledge = 678
    project.maxPledge = 999_999
    project.fxRate = 1.0
    project.stateChangedAt = "232434"
    project.location = GraphAPITestMocks.Location.mock
    project.canComment = true
    project.state = .case(.live)
    project.creator = GraphAPITestMocks.User.mock
    project.url = "https://ksr.com/project/the-project"
    project.availableCardTypes = [.case(.visa), .case(.amex)]
    project.isLaunched = true
    project.tags = []
    project.slug = "the-project"
    project.risks = "risks"
    project.story = "story"
    project.description = "project description"
    project.isWatched = false
    project.isInPostCampaignPledgingPhase = false
    project.postCampaignPledgingEnabled = true
    project.prelaunchActivated = false
    project.redemptionPageUrl = "https://ksr.com/the-project/redemption"
    project.sendMetaCapiEvents = false
    project.isProjectWeLove = false
    project.pledged = Mock<GraphAPITestMocks.Money>()
    project.pledged?.amount = "999.99"
    project.pledged?.currency = .case(.usd)
    project.pledged?.symbol = "$"
    project.backersCount = 9_183
    project.commentsCount = 666
    project.isPledgeOverTimeAllowed = true
    project.image = Mock<GraphAPITestMocks.Photo>()
    project.image?.id = "aW1hZ2UtOTI0"
    project.image?.url = "https://ksr.com/a-project-photo.jpg"
    project.image?.altText = "A Photo"
    project.category = Mock<GraphAPITestMocks.Category>()
    project.category?.id = "Y2F0ZWdvcnktNTU2NA=="
    project.category?.name = "The category"
    project.category?.analyticsName = "the-category"
    return project
  }
}
