import Combine
import Foundation
import KsApi
import Library

typealias PPOViewModelPaginator = Paginator<
  GraphAPI.FetchPledgedProjectsQuery.Data,
  PPOProjectCardViewModel,
  String,
  ErrorEnvelope,
  Void
>

protocol PPOViewModelInputs {
  func viewDidAppear()
  func loadMore()
  func pullToRefresh()
}

protocol PPOViewModelOutputs {
  var results: PPOViewModelPaginator.Results { get }
}

final class PPOViewModel: ObservableObject, PPOViewModelInputs, PPOViewModelOutputs {
  init() {
    let paginator: PPOViewModelPaginator = Paginator(
      valuesFromEnvelope: { data in
        let nodes = data.pledgeProjectsOverview?.pledges?.edges?.compactMap { $0?.node } ?? []
        let viewModels = nodes.compactMap { PPOProjectCardViewModel(node: $0) }
        return viewModels
      },
      cursorFromEnvelope: { data in
        let hasNextPage = data.pledgeProjectsOverview?.pledges?.pageInfo.hasNextPage ?? false
        guard hasNextPage else {
          return nil
        }
        return data.pledgeProjectsOverview?.pledges?.pageInfo.endCursor
      },
      requestFromParams: { () in
        AppEnvironment.current.apiService.fetchPledgedProjects(cursor: nil, limit: Constants.pageSize)
      },
      requestFromCursor: { cursor in
        AppEnvironment.current.apiService.fetchPledgedProjects(cursor: cursor, limit: Constants.pageSize)
      }
    )
    self.paginator = paginator

    paginator.$results
      .drop(while: { results in
        if case .unloaded = results {
          return true
        } else {
          return false
        }
      })
      .receive(on: RunLoop.main)
      .assign(to: &self.$results)

    Publishers.Merge(
      self.viewDidAppearSubject
        .first(),
      self.pullToRefreshSubject
    )
    .sink { () in
      paginator.requestFirstPage()
    }
    .store(in: &self.cancellables)

    self.loadMoreSubject
      .sink { () in
        paginator.requestNextPage()
      }
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func viewDidAppear() {
    self.viewDidAppearSubject.send(())
  }

  func loadMore() {
    self.loadMoreSubject.send(())
  }

  func pullToRefresh() {
    self.pullToRefreshSubject.send(())
  }

  // MARK: - Outputs

  @Published var results = PPOViewModelPaginator.Results.unloaded

  // MARK: - Private

  private let paginator: PPOViewModelPaginator

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 20
  }
}
