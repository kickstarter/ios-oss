import KsApi
import Prelude
import ReactiveSwift

public protocol CuratedProjectsViewModelInputs {
  func configure(with categories: [KsApi.Category])
  func doneButtonTapped()
  func viewDidLoad()
}

public protocol CuratedProjectsViewModelOutputs {
  var loadProjects: Signal<[Project], Never> { get }
  var dismissViewController: Signal<Void, Never> { get }
}

public protocol CuratedProjectsViewModelType {
  var inputs: CuratedProjectsViewModelInputs { get }
  var outputs: CuratedProjectsViewModelOutputs { get }
}

final public class CuratedProjectsViewModel: CuratedProjectsViewModelType, CuratedProjectsViewModelInputs,
CuratedProjectsViewModelOutputs {
  public init() {
    let projectsPerPage = self.categoriesSignal
      .map(\.count)
      .map { Int(floor(Float(30/$0))) }

    let params: Signal<[DiscoveryParams], Never> = self.categoriesSignal
      .combineLatest(with: projectsPerPage)
      .map(categoryToParams(_:perPage:))

    let projectsEvents = params
      .takeWhen(self.viewDidLoadSignal)
      .switchMap(projectsFrom(params:))

    self.loadProjects = projectsEvents

    self.dismissViewController = self.doneButtonTappedSignal
  }

  private let (categoriesSignal, categoriesObserver) = Signal<[KsApi.Category], Never>.pipe()
  public func configure(with categories: [KsApi.Category]) {
    self.categoriesObserver.send(value: categories)
  }

  private let (doneButtonTappedSignal, doneButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func doneButtonTapped() {
    self.doneButtonTappedObserver.send(value: ())
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<Void, Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let dismissViewController: Signal<Void, Never>
  public let loadProjects: Signal<[Project], Never>

  public var inputs: CuratedProjectsViewModelInputs { return self }
  public var outputs: CuratedProjectsViewModelOutputs { return self }
}

private func categoryToParams(_ categories: [KsApi.Category], perPage: Int) -> [DiscoveryParams] {
  return categories.map {
    DiscoveryParams.defaults
      |> DiscoveryParams.lens.category .~ $0
      |> DiscoveryParams.lens.perPage .~ perPage
  }
}

private func projectsFrom(params: [DiscoveryParams]) -> SignalProducer<[Project], Never> {
  let producer: SignalProducer<[[Project]], Never> = SignalProducer(value: [])

  params.forEach {
    let projects = AppEnvironment.current.apiService.fetchDiscovery(params: $0)
      .map { $0.projects }
      .demoteErrors(replaceErrorWith: [])

    projects.uncollect().allValues().forEach { v in
      print(v)
    }

    _ = producer.concat([projects], { curr, new in curr + new })
  }

  print(producer.uncollect().allValues())

  return producer.uncollect()
}
