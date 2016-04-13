import Models
import KsApi
import ReactiveCocoa
import Result
import ReactiveExtensions
import struct Library.Environment
import struct Library.AppEnvironment

protocol _PlaylistInputs {
  func nextItem()
  func previousItem()
}

protocol _PlaylistOutputs {
  var currentProject: SignalProducer<Project, NoError> { get }
}

// swiftlint:disable type_name
final class _Playlist: _PlaylistInputs, _PlaylistOutputs {
  enum Type {
    case Featured(Models.Category?)
    case Recommended(Models.Category?)
    case Popular(Models.Category?)
  }

  let apiService: ServiceType
  let seed: Int
  let type: Type

  var currentItem = MutableProperty<Int?>(nil)
  var totalItems: Int?
  var projects: [Project] = []

  func nextItem() {
    guard let item = self.currentItem.value,
      total = totalItems else { return }
    self.currentItem.value = min(min(total, self.projects.count - 1), item + 1)
  }
  func previousItem() {
    guard let item = self.currentItem.value else { return }
    self.currentItem.value = max(0, item - 1)
  }

  init(type: Type, env: Environment = AppEnvironment.current) {
    self.apiService = env.apiService
    self.seed = Int(arc4random_uniform(1_000_000))
    self.type = type
  }

  var currentProject: SignalProducer<Project, NoError> {

    return self.currentItem.producer
      .switchMap(self.projectForItem)
  }

  private func projectForItem(item: Int?) -> SignalProducer<Project, NoError> {
    if let item = item {
      return SignalProducer(value: self.projects[item])
    }

    return self.apiService.fetchDiscovery(self.discoveryParams)
      .demoteErrors()
      .on(next: { env in
        self.totalItems = env.stats.count
        self.projects = env.projects
        self.currentItem.value = 0
      })
      .map { env in env.projects.first }
      .ignoreNil()
  }

  var discoveryParams: DiscoveryParams {
    switch self.type {
    case let .Featured(category):
      return DiscoveryParams(
        staffPicks: true,
        hasVideo: true,
        category: category,
        state: .Live,
        includePOTD: true,
        seed: self.seed
      )
    case let .Recommended(category):
      return DiscoveryParams(
        hasVideo: true,
        recommended: true,
        category: category,
        state: .Live,
        seed: self.seed
      )
    case let .Popular(category):
        return DiscoveryParams(
          hasVideo: true,
          category: category,
          state: .Live,
          sort: .Popular,
          seed: self.seed
      )
    }
  }

  var category: Models.Category? {
    switch self.type {
    case let .Featured(category):
      return category
    case let .Recommended(category):
      return category
    case let .Popular(category):
      return category
    }
  }
}

enum Playlist {

  case Featured
  case Recommended
  case Popular
  case CategoryFeatured(Models.Category)
  case Category(Models.Category)

  var discoveryParams: DiscoveryParams {
    switch self {
    case Featured:
      return DiscoveryParams(staffPicks: true, hasVideo: true, state: .Live, includePOTD: true)
    case .Recommended:
      return DiscoveryParams(hasVideo: true, recommended: true, state: .Live)
    case .Popular:
      return DiscoveryParams(hasVideo: true, state: .Live, sort: .Popular)
    case let .CategoryFeatured(category):
      return DiscoveryParams(hasVideo: true, category: category, state: .Live)
    case let .Category(category):
      return DiscoveryParams(hasVideo: true, category: category, state: .Live)
    }
  }

  var sampleProjectParams: DiscoveryParams {
    return self.discoveryParams.with(perPage: 1)
  }

  var category: Models.Category? {
    switch self {
    case .Featured, .Recommended, .Popular:
      return nil
    case let .CategoryFeatured(category):
      return category
    case let .Category(category):
      return category
    }
  }
}

extension Playlist: Equatable {
}

func == (lhs: Playlist, rhs: Playlist) -> Bool {
  switch (lhs, rhs) {
  case (.Featured, .Featured), (.Recommended, .Recommended), (.Popular, .Popular):
    return true
  case let (.Category(lhs), .Category(rhs)):
    return lhs == rhs
  case let (.CategoryFeatured(lhs), .CategoryFeatured(rhs)):
    return lhs == rhs
  default:
    return false
  }
}
