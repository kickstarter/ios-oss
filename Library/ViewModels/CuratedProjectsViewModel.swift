import KsApi
import Prelude
import ReactiveSwift

public protocol CuratedProjectsViewModelInputs {
  func configure(with categories: [KsApi.Category])
}

public protocol CuratedProjectsViewModelOutputs {
  var loadProjects: Signal<[Project], Never> { get }
}

protocol CuratedProjectsViewModelType {
  var inputs: CuratedProjectsViewModelInputs { get }
  var outputs: CuratedProjectsViewModelOutputs { get }
}

final public class CuratedProjectsViewModel: CuratedProjectsViewModelType, CuratedProjectsViewModelInputs,
CuratedProjectsViewModelOutputs {
  public init() {
    let projectsPerPage = self.categoriesSignal
      .map(\.count)
      .map { Int(floor(30/$0)) }

    let params = self.categoriesSignal
      .zip(with: projectsPerPage)
      .map { category, perPage in
        DiscoveryParams.defaults
        |> \.category .~ category
        |> \.perPage .~ perPage
      }

    let projectsEvents = params
      .map { param -> SignalProducer<[Project], Never> in
        AppEnvironment.current.apiService.fetchDiscovery(params: param)
        .map { $0.projects }
        .demoteErrors()
      }


    self.loadProjects = .empty
  }

  private let (categoriesSignal, categoriesObserver) = Signal<[KsApi.Category], Never>.pipe()
  public func configure(with categories: [KsApi.Category]) {
    self.categoriesObserver.send(value: categories)
  }

  public let loadProjects: Signal<[Project], Never>

  public var inputs: CuratedProjectsViewModelInputs { return self }
  public var outputs: CuratedProjectsViewModelOutputs { return self }
}

