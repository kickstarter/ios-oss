import Models
import KsApi
import ReactiveCocoa
import Result
import ReactiveExtensions
import Prelude
import Library

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

    return self.apiService.fetchDiscovery(params: self.discoveryParams)
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
    let base = DiscoveryParams.lens.seed .~ self.seed
      <> DiscoveryParams.lens.state .~ .Live
      <> DiscoveryParams.lens.hasVideo .~ true

    switch self.type {
    case let .Featured(category):
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.staffPicks .~ true
        <> DiscoveryParams.lens.includePOTD .~ true
        <> DiscoveryParams.lens.category .~ category

    case let .Recommended(category):
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.category .~ category
        <> DiscoveryParams.lens.recommended .~ true

    case let .Popular(category):
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.category .~ category
        <> DiscoveryParams.lens.sort .~ .Popular
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
    let base = DiscoveryParams.lens.hasVideo .~ true <> DiscoveryParams.lens.state .~ .Live

    switch self {
    case Featured:
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.staffPicks .~ true
        <> DiscoveryParams.lens.includePOTD .~ true

    case .Recommended:
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.recommended .~ true

    case .Popular:
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.sort .~ .Popular

    case let .CategoryFeatured(category):
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.category .~ category

    case let .Category(category):
      return DiscoveryParams.defaults |> base
        <> DiscoveryParams.lens.category .~ category
    }
  }

  var sampleProjectParams: DiscoveryParams {
    return self.discoveryParams |> DiscoveryParams.lens.perPage .~ 1
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
