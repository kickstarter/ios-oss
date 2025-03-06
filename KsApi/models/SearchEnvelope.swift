import Foundation
import ReactiveSwift

public protocol BackerDashboardCellProject {
  var id: Int { get }
  var name: String { get }
  var state: Project.State { get }
  var imageURL: String { get }
  var fundingProgress: Float { get }
  var percentFunded: Int { get }
  var displayPrelaunch: Bool? { get }
  var prelaunchActivated: Bool? { get }
  var launchedAt: TimeInterval? { get }
  var deadline: TimeInterval? { get }
  var isStarred: Bool? { get }
}

public struct SearchProject: Equatable {
  public let cell: any BackerDashboardCellProject
  public let analytics: any ProjectAnalyticsProperties
}

public func == (lhs: SearchProject, rhs: SearchProject) -> Bool {
  return lhs.cell.id == rhs.cell.id
}

public struct SearchEnvelope {
  public let projects: [SearchProject]
  public let count: Int
  public let moreProjectsCursor: String?
}

extension SearchEnvelope {
  static func from(data: GraphAPI.SearchQueryQuery.Data) -> SearchEnvelope? {
    let projects = data.projects?.nodes?
      .compactMap { (node: GraphAPI.SearchQueryQuery.Data.Project.Node?) -> SearchProject? in
        guard let cell = node?.fragments.searchCellProjectFragment,
              let analytics = node?.fragments.projectAnalyticsFragment else {
          return nil
        }

        return SearchProject(cell: cell, analytics: analytics)
      }

    let hasMore = data.projects?.pageInfo.hasNextPage ?? false

    return SearchEnvelope(
      projects: projects ?? [],
      count: data.projects?.totalCount ?? 0,
      moreProjectsCursor: hasMore ? data.projects?.pageInfo.endCursor : nil
    )
  }

  static func envelopeProducer(
    from data: GraphAPI.SearchQueryQuery.Data
  ) -> SignalProducer<SearchEnvelope, ErrorEnvelope> {
    guard let envelope = SearchEnvelope.from(data: data) else { return .empty }

    return SignalProducer(value: envelope)
  }
}

extension GraphAPI.SearchCellProjectFragment: BackerDashboardCellProject {
  public var id: Int {
    return Int(self.projectId) ?? -1
  }

  public var prelaunchActivated: Bool? {
    return Optional.some(self.projectPrelaunchActivated)
  }

  public var state: KsApi.Project.State {
    return Project.State(rawValue: self.projectState.rawValue.lowercased()) ?? Project.State.live
  }

  public var imageURL: String {
    self.image?.url ?? ""
  }

  public var fundingProgress: Float {
    let pledged = self.pledged.fragments.moneyFragment.amount.flatMap(Float.init) ?? 0

    let goal = self.goal?.fragments.moneyFragment.amount.flatMap(Float.init).flatMap(Int.init) ?? 0

    return goal == 0 ? 0.0 : Float(pledged) / Float(goal)
  }

  public var percentFunded: Int {
    return Int(floor(self.fundingProgress * 100.0))
  }

  public var displayPrelaunch: Bool? {
    return !self.isLaunched
  }

  public var launchedAt: TimeInterval? {
    return self.projectLaunchedAt.flatMap(TimeInterval.init)
  }

  public var deadline: TimeInterval? {
    return self.deadlineAt.flatMap(TimeInterval.init)
  }

  public var isStarred: Bool? {
    return self.isWatched
  }
}
