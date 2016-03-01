import Models
import KsApi
import ReactiveCocoa
import Result

protocol SearchViewModelInputs {
  func updateQuery(query: String)
}

protocol SearchViewModelOutputs {
  var projects: SignalProducer<[Project], NoError> { get }
}

final class SearchViewModel: SearchViewModelInputs, SearchViewModelOutputs {
  // MARK : Inputs
  var inputs: SearchViewModelInputs { return self }
  private let (querySignal, queryObserver) = Signal<String, NoError>.pipe()
  func updateQuery(query: String) {
    queryObserver.sendNext(query)
  }

  //MARK : Outputs
  var outputs: SearchViewModelOutputs { return self }
  var projects: SignalProducer<[Project], NoError>

  init(env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    let (projectsSignal, projectsObserver) = SignalProducer<[Project], NoError>.buffer(1)
    self.projects = projectsSignal

    querySignal
      .throttle(0.3, onScheduler: QueueScheduler.mainQueueScheduler)
      .switchMap { (query) -> SignalProducer<[Project], NoError> in
        if query.isEmpty {
          return apiService.fetchProjects(DiscoveryParams(sort: .Popular)).demoteErrors()
        }
        return apiService.fetchProjects(DiscoveryParams(query: query)).demoteErrors()
      }
      .observe(projectsObserver)
  }
}
