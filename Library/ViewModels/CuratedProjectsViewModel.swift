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

public final class CuratedProjectsViewModel: CuratedProjectsViewModelType, CuratedProjectsViewModelInputs,
  CuratedProjectsViewModelOutputs {
  public init() {
    let projectsPerCategory = self.categoriesSignal
      .map(\.count)
      .map { Int(floor(Float(30 / $0))) }

    let scheduler = QueueScheduler(qos: .background, name: "com.kickstarter.library", targeting: nil)

    let curatedProjects: Signal<[Project], Never> = self.categoriesSignal
      .combineLatest(with: projectsPerCategory)
      .observe(on: scheduler)
      .switchMap { (arg) -> SignalProducer<[Project], Never> in
        let (categories, perPage) = arg
        return projects(from: categories, perPage: perPage)
      }

    self.loadProjects = curatedProjects
      .takeWhen(self.viewDidLoadSignal.ignoreValues())

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

private func projects(from categories: [KsApi.Category], perPage: Int)
  -> SignalProducer<[Project], Never> {
  var fetchedProjects: [Project] = []

  categories.forEach { category in

    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.category .~ category
      |> DiscoveryParams.lens.perPage .~ perPage

    let projects = AppEnvironment.current.apiService.fetchDiscovery(params: params)
      .demoteErrors()
      .map { $0.projects }
      .allValues()
      .flatMap { $0 }

    fetchedProjects.append(contentsOf: projects)
  }

  return SignalProducer(value: fetchedProjects)
}
