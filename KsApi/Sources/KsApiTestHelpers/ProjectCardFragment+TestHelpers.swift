import ApolloTestSupport
import Foundation
import GraphAPI
import GraphAPITestMocks
import KsApi

extension GraphAPI.ProjectCardFragment {
  // Returns a `Query` mock with all the fields required to parse `ProjectCardFragment`s through a
  // `ProjectsConnection` node.
  // This can for example be used to create a mock for the FetchMyBackedProjects query.
  public static func mockProjectsConnectionQuery(numberOfProjects: Int) -> Mock<GraphAPITestMocks.Query> {
    let projects: [Mock<GraphAPITestMocks.Project>?]
    if numberOfProjects > 0 {
      projects = (1...numberOfProjects).map { self.mockProject(id: $0) }
    } else {
      projects = []
    }

    let pageInfo = Mock<PageInfo>()
    pageInfo.hasNextPage = true
    pageInfo.hasPreviousPage = false

    let projectsConnectionMock = Mock<GraphAPITestMocks.ProjectsConnectionWithTotalCount>(
      nodes: projects,
      pageInfo: pageInfo,
      totalCount: numberOfProjects
    )

    let queryMock = Mock<GraphAPITestMocks.Query>.init()
    queryMock.projects = projectsConnectionMock
    return queryMock
  }

  // Returns a project mock consisting of all the fields required to create a `ProjectCardFragment`.
  public static func mockProject(id: Int = 0) -> Mock<GraphAPITestMocks.Project> {
    let image = Mock<GraphAPITestMocks.Photo>()
    image.url = "www.example.com"
    image.id = "fakeImageId"

    let country = Mock<GraphAPITestMocks.Country>()
    country.code = .case(.us)
    country.name = "United States"

    let pledged = Mock<GraphAPITestMocks.Money>()

    let posts = Mock<GraphAPITestMocks.PostConnection>()
    posts.totalCount = 2

    let project = Mock<GraphAPITestMocks.Project>()
    project.id = "\(id)"
    project.image = image
    project.name = "Test project"
    project.pid = id
    project.state = .case(.live)
    project.isLaunched = true
    project.percentFunded = 200
    project.prelaunchActivated = true
    project.isInPostCampaignPledgingPhase = false
    project.postCampaignPledgingEnabled = false
    project.url = "fakeUrl"
    project.isWatched = false
    project.pledged = pledged
    project.backersCount = 20
    project.commentsCount = 1
    project.country = country
    project.currency = .case(.usd)
    project.isPrelaunchActivated = false
    project.projectTags = []
    project.fxRate = 0.0
    project.posts = posts
    project.projectDescription = "description"
    project.stateChangedAt = "none"
    project.projectUsdExchangeRate = 0.0
    project.risks = "risks"
    return project
  }
}
