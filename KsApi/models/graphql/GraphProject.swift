import Foundation
import Prelude

public struct GraphProject: Swift.Decodable {
  public var actions: Actions
  public var addOns: AddOns?
  public var backersCount: Int
  public var category: GraphCategory?
  public var country: GraphCountry?
  public var creator: GraphUser
  public var currency: String
  public var deadlineAt: TimeInterval?
  public var description: String
  public var finalCollectionDate: String?
  public var fxRate: Double
  public var goal: Money?
  public var image: Image?
  public var isProjectWeLove: Bool?
  public var launchedAt: TimeInterval?
  public var location: GraphLocation?
  public var name: String
  public var pid: Int
  public var pledged: Money
  public var prelaunchActivated: Bool?
  public var rewards: Rewards?
  public var slug: String
  public var state: ProjectState
  public var stateChangedAt: TimeInterval
  public var url: String

  public struct Actions: Swift.Decodable {
    public var displayConvertAmount: Bool
  }

  public struct AddOns: Swift.Decodable {
    public var nodes: [GraphReward]
  }

  public struct Image: Swift.Decodable {
    public var id: String
    public var url: String
  }

  public struct Rewards: Swift.Decodable {
    public var nodes: [GraphReward]
  }
}

extension GraphProject {
  /// All properties required to instantiate a `Project` via a `GraphProject`
  static var baseQueryProperties: NonEmptySet<Query.Project> {
    return Query.Project.pid +| [
      .actions(.displayConvertAmount +| []),
      .deadlineAt,
      .image(.id +| [.url(width: Constants.imageWidth)]),
      .launchedAt,
      .location(GraphLocation.baseQueryProperties),
      .backersCount,
      .category(GraphCategory.baseQueryProperties),
      .country(.code +| [.name]),
      .creator(GraphUser.baseQueryProperties),
      .currency,
      .description,
      .fxRate,
      .isProjectWeLove,
      .name,
      .goal(Money.baseQueryProperties),
      .pledged(Money.baseQueryProperties),
      .slug,
      .state,
      .stateChangedAt,
      .url
    ]
  }
}
