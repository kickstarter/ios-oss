@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class OptimizelyFeatureHelpersTests: TestCase {
  fileprivate var cosmicSurgery: Project!

  override func setUp() {
    super.setUp()
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let launchedAt = self.dateType.init().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 14.0
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.dates.launchedAt .~ launchedAt
      |> Project.lens.stats.convertedPledgedAmount .~ 21_615

    self.cosmicSurgery = project
  }

  func testCommentsViewController_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreading.rawValue: true]

    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)

    let mockService = MockService(fetchProjectResponse: project)

    withEnvironment(
      apiService: mockService, optimizelyClient: mockOptimizelyClient
    ) {
      XCTAssert(commentsViewController(for: project).isKind(of: CommentsViewController.self))
    }
  }

  func testCommentsViewController_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreading.rawValue: false]

    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)

    let mockService = MockService(fetchProjectResponse: project)

    withEnvironment(
      apiService: mockService, optimizelyClient: mockOptimizelyClient
    ) {
      XCTAssert(commentsViewController(for: project).isKind(of: DeprecatedCommentsViewController.self))
    }
  }
}
