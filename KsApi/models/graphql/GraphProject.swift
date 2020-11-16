import Foundation
import Prelude

struct GraphProject: Decodable {
  var actions: Actions
  var addOns: AddOns?
  var backersCount: Int
  var category: GraphCategory?
  var country: GraphCountry?
  var creator: GraphUser
  var currency: String
  var deadlineAt: TimeInterval?
  var description: String
  var finalCollectionDate: String?
  var fxRate: Double
  var goal: Money?
  var image: Image?
  var isProjectWeLove: Bool?
  var launchedAt: TimeInterval?
  var location: GraphLocation?
  var name: String
  var pid: Int
  var pledged: Money
  var prelaunchActivated: Bool?
  var rewards: Rewards?
  var slug: String
  var state: ProjectState
  var stateChangedAt: TimeInterval
  var url: String
  var usdExchangeRate: Double?

  struct Actions: Decodable {
    var displayConvertAmount: Bool
  }

  struct AddOns: Decodable {
    var nodes: [GraphReward]
  }

  struct Image: Decodable {
    var id: String
    var url: String
  }

  struct Rewards: Decodable {
    var nodes: [GraphReward]
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
      .url,
      .usdExchangeRate
    ]
  }
}
