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

  func openBackedProjects()
  func fixPaymentMethod()
  func fix3DSChallenge()
  func openSurvey()
  func confirmAddress()
  func contactCreator()
}

protocol PPOViewModelOutputs {
  var results: PPOViewModelPaginator.Results { get }
  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> { get }
}

enum PPONavigationEvent {
  case backingPage
  case fixPaymentMethod
  case fix3DSChallenge
  case survey
  case confirmAddress
  case contactCreator
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

    // TODO: Send actual banner messages in response to card actions instead.
    self.shouldSendSampleMessageSubject
      .sink { [weak self] _ in
//        self?.bannerViewModel = MessageBannerViewViewModel((
//          .success,
//          "Survey submitted! Need to change your address? Visit your backing details on our website."
//        ))
        self?.bannerViewModel = MessageBannerViewViewModel((.success, "Your payment has been processed."))
      }
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func shouldSendSampleMessage() {
    self.shouldSendSampleMessageSubject.send(())
  }

  func viewDidAppear() {
    self.viewDidAppearSubject.send(())
  }

  func loadMore() {
    self.loadMoreSubject.send(())
  }

  func pullToRefresh() {
    self.pullToRefreshSubject.send(())
  }

  func openBackedProjects() {
    self.navigationEventSubject.send(.backingPage)
  }

  func fixPaymentMethod() {
    self.navigationEventSubject.send(.fixPaymentMethod)
  }

  func fix3DSChallenge() {
    self.navigationEventSubject.send(.fix3DSChallenge)
  }

  func openSurvey() {
    self.navigationEventSubject.send(.survey)
  }

  func confirmAddress() {
    self.navigationEventSubject.send(.confirmAddress)
  }

  func contactCreator() {
    self.navigationEventSubject.send(.contactCreator)
  }

  // MARK: - Outputs

  @Published var bannerViewModel: MessageBannerViewViewModel? = nil
  @Published var results = PPOViewModelPaginator.Results.unloaded

  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> {
    navigationEventSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private let paginator: PPOViewModelPaginator

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
  private let shouldSendSampleMessageSubject = PassthroughSubject<(), Never>()

  private var navigationEventSubject = PassthroughSubject<PPONavigationEvent, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 20
  }
}
