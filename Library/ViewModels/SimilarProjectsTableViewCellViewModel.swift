import KsApi
import Prelude
import ReactiveSwift
import UIKit

public struct SimilarProjectsData {
  public var projects: [any SimilarProject]
  public var loading: Bool
}

public protocol SimilarProjectsTableViewCellViewModelInputs {
  func fetchSimilarProjects()
}

public protocol SimilarProjectsTableViewCellViewModelOutputs {
  /// Emits a list of `any SimilarProject`.
  var similarProjects: Signal<SimilarProjectsData, Never> { get }
}

public protocol SimilarProjectsTableViewCellViewModelType {
  var inputs: SimilarProjectsTableViewCellViewModelInputs { get }
  var outputs: SimilarProjectsTableViewCellViewModelOutputs { get }
}

public final class SimilarProjectsTableViewCellViewModel: SimilarProjectsTableViewCellViewModelType,
  SimilarProjectsTableViewCellViewModelInputs,
  SimilarProjectsTableViewCellViewModelOutputs {
  public init() {
    self.similarProjects = self.fetchSimilarProjectsProperty.signal
      .map {
        let validProjectFragment = createMockProjectNode()

        guard let similarProject = SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment)
        else { return SimilarProjectsData(projects: [], loading: false) }

        // Return 'nil' for now until the feature flagging code is available.
//        return (project, nil)
        return SimilarProjectsData(
          projects: [similarProject, similarProject, similarProject, similarProject],
          loading: false
        )
      }
  }

  fileprivate let fetchSimilarProjectsProperty = MutableProperty(())
  public func fetchSimilarProjects() {
    self.fetchSimilarProjectsProperty.value = ()
  }

  public let similarProjects: Signal<SimilarProjectsData, Never>

  public var inputs: SimilarProjectsTableViewCellViewModelInputs { return self }
  public var outputs: SimilarProjectsTableViewCellViewModelOutputs { return self }
}

// TODO: Remove this when Similar Projects GraphAPI Call is hooked up.
// Helper method to create mock project nodes for testing
private func createMockProjectNode(
  id: Int = 123,
  name: String = "Test Project",
  imageURL: String? = "https://example.com/image.jpg",
  state: String = "live",
  isLaunched: Bool = true,
  prelaunchActivated: Bool = false,
  launchedAt: String? = "1741737648",
  deadlineAt: String? = "1742737648",
  percentFunded: Int = 75,
  goal: Double? = 10_000,
  pledged: Double = 7_500,
  isInPostCampaignPledgingPhase: Bool = false,
  isPostCampaignPledgingEnabled: Bool = false
) -> GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node {
  var resultMap: [String: Any] = [
    "__typename": "Project",
    "pid": id,
    "name": name,
    "state": GraphAPI.ProjectState(rawValue: state) ?? GraphAPI.ProjectState.__unknown(state),
    "isLaunched": isLaunched,
    "prelaunchActivated": prelaunchActivated,
    "percentFunded": percentFunded,
    "pledged": [
      "__typename": "Money",
      "amount": String(pledged),
      "currency": GraphAPI.CurrencyCode.usd,
      "symbol": "$"
    ],
    "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
    "postCampaignPledgingEnabled": isPostCampaignPledgingEnabled
  ]

  // Add optional fields
  if let imageURL {
    resultMap["image"] = [
      "__typename": "Photo",
      "url": imageURL
    ]
  }

  if let launchedAt {
    resultMap["launchedAt"] = launchedAt
  }

  if let deadlineAt {
    resultMap["deadlineAt"] = deadlineAt
  }

  if let goal {
    resultMap["goal"] = [
      "__typename": "Money",
      "amount": String(goal),
      "currency": GraphAPI.CurrencyCode.usd,
      "symbol": "$"
    ]
  }

  return GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node(unsafeResultMap: resultMap)
}
