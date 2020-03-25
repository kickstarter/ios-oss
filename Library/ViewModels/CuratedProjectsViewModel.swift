import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol CuratedProjectsViewModelInputs {
  func configure(with categories: [KsApi.Category])
  func doneButtonTapped()
  func viewDidLoad()
}

public protocol CuratedProjectsViewModelOutputs {
  var dismissViewController: Signal<Void, Never> { get }
  var isLoading: Signal<Bool, Never> { get }
  var loadProjects: Signal<[Project], Never> { get }
}

public protocol CuratedProjectsViewModelType {
  var inputs: CuratedProjectsViewModelInputs { get }
  var outputs: CuratedProjectsViewModelOutputs { get }
}

public final class CuratedProjectsViewModel: CuratedProjectsViewModelType, CuratedProjectsViewModelInputs,
  CuratedProjectsViewModelOutputs {
  public init() {
    let curatedProjects: Signal<[Project], Never> = self.categoriesSignal
      .combineLatest(with: self.viewDidLoadSignal.ignoreValues())
      .flatMap { categories, _ in
        projects(from: categories)
          .flatten()
          .reduce([], +)
    }
    .map { $0.shuffled() }

    self.loadProjects = curatedProjects

    self.dismissViewController = self.doneButtonTappedSignal

    self.isLoading = Signal.merge(
      self.viewDidLoadSignal.mapConst(true),
      curatedProjects.mapConst(false)
    )
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
  public let isLoading: Signal<Bool, Never>
  public let loadProjects: Signal<[Project], Never>

  public var inputs: CuratedProjectsViewModelInputs { return self }
  public var outputs: CuratedProjectsViewModelOutputs { return self }
}

private func projects(from categories: [KsApi.Category])
  -> SignalProducer<[[Project]], Never> {
  return SignalProducer.combineLatest(producers(from: categories))
}

private func producers(from categories: [KsApi.Category])
  -> [SignalProducer<[Project], Never>] {
  let projectsPerCategory = Int(floor(Float(30 / categories.count)))

  return categories.map { category in

    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.category .~ category
      |> DiscoveryParams.lens.perPage .~ projectsPerCategory

    return AppEnvironment.current.apiService.fetchDiscovery(params: params)
      .map { $0.projects }
      .demoteErrors(replaceErrorWith: [])
  }
}
