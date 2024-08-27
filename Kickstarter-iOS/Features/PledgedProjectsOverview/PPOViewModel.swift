import Combine
import Foundation
import KsApi
import Library

enum Loadable<T, E: Error> {
  case notStarted
  case loading(data: T?)
  case loaded(data: T, nextCursor: String?)
  case empty
  case failed(E)

  var data: T? {
    switch self {
    case let .loading(data):
      data
    case let .loaded(data, _):
      data
    case .notStarted, .empty, .failed:
      nil
    }
  }
}

protocol PPOViewModelInputs {
  func viewDidAppear()
  func confirmAddress()
  func fixPaymentMethod()
  func fix3DSChallenge()
  func updateAddress()
  func goToSurvey()
  func viewBackingDetails()
  func contactCreator()
}

protocol PPOViewModelOutputs {
  var state: Loadable<[PPOProjectCardViewModel], ErrorEnvelope> { get }
}

final class PPOViewModel: ObservableObject, PPOViewModelInputs, PPOViewModelOutputs {
  init(service: any ServiceType = AppEnvironment.current.apiService) {
    self.service = service

    let loadInitial = self.viewDidAppearSubject
      .first()
      .map { () -> String? in nil }

    let loadMore = self.loadMoreSubject
      .map { [weak self] _ -> String? in
        guard let self else { return nil }
        switch self.state {
        case let .loaded(_, cursor):
          return cursor
        case .notStarted, .loading, .failed, .empty:
          return nil
        }
      }

    Publishers.Merge(loadInitial, loadMore)
      .flatMap { [weak self] cursor -> AnyPublisher<Loadable<[PPOProjectCardViewModel], ErrorEnvelope>, Never> in
        guard let self else { return Empty().eraseToAnyPublisher() }
        return self.fetch(cursor: cursor).eraseToAnyPublisher()
      }
      .sink { [weak self] loadable in
        self?.state = loadable
      }
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func viewDidAppear() {
    self.viewDidAppearSubject.send(())
  }

  func loadMoreProjects() {
    self.loadMoreSubject.send(())
  }

  func confirmAddress() {
    self.confirmAddressSubject.send(())
  }

  func fixPaymentMethod() {
    self.fixPaymentMethodSubject.send(())
  }

  func fix3DSChallenge() {
    self.fix3DSChallengeSubject.send(())
  }

  func updateAddress() {
    self.updateAddressSubject.send(())
  }

  func goToSurvey() {
    self.goToSurveySubject.send(())
  }

  func viewBackingDetails() {
    self.viewBackingDetailsSubject.send(())
  }

  func contactCreator() {
    self.contactCreatorSubject.send(())
  }

  // MARK: - Outputs

  @Published private(set) var state: Loadable<[PPOProjectCardViewModel], ErrorEnvelope> = .notStarted

  // MARK: - Private

  private func fetch(cursor: String?) -> AnyPublisher<Loadable<[PPOProjectCardViewModel], ErrorEnvelope>, Never> {
    self.service.fetchPledgedProjects(cursor: cursor, limit: nil)
      .map { data -> ([PPOProjectCardViewModel], String?) in
        let edges = data.pledgeProjectsOverview?.pledges?.edges ?? []
        let items = edges.compactMap { $0?.node }
          .compactMap({ node in PPOProjectCardViewModel(node: node) })
        let cursor = data.pledgeProjectsOverview?.pledges?.pageInfo.endCursor
        let hasNextPage = data.pledgeProjectsOverview?.pledges?.pageInfo.hasNextPage ?? false
        return (items, hasNextPage ? cursor : nil)
      }
      .map({ (newViewModels, cursor) -> Loadable<[PPOProjectCardViewModel], ErrorEnvelope> in
        let allViewModels: [PPOProjectCardViewModel]
        if case let .loading(previousProjects) = self.state, let previous = previousProjects {
          allViewModels = previous + newViewModels
        } else {
          allViewModels = newViewModels
        }
        return allViewModels.isEmpty ? .empty : .loaded(data: allViewModels, nextCursor: cursor)
      })
      .prepend(.loading(data: self.state.data))
      .catch({ error in
        Just(.failed(error))
      })
      .eraseToAnyPublisher()
  }

  private let service: any ServiceType

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let projectTappedSubject = PassthroughSubject<Project, Never>()
  private let backButtonTappedSubject = PassthroughSubject<Void, Never>()
  private let filterButtonTappedSubject = PassthroughSubject<Void, Never>()
  private let confirmAddressSubject = PassthroughSubject<Void, Never>()
  private let fixPaymentMethodSubject = PassthroughSubject<Void, Never>()
  private let fix3DSChallengeSubject = PassthroughSubject<Void, Never>()
  private let updateAddressSubject = PassthroughSubject<Void, Never>()
  private let goToSurveySubject = PassthroughSubject<Void, Never>()
  private let viewBackingDetailsSubject = PassthroughSubject<Void, Never>()
  private let contactCreatorSubject = PassthroughSubject<Void, Never>()

  private var cancellables: Set<AnyCancellable> = []
}
