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
      totalFromEnvelope: { data in
        data.pledgeProjectsOverview?.pledges?.totalCount
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

    // Route navigation events
    Publishers.Merge6(
      self.openBackedProjectsSubject.map { PPONavigationEvent.backingPage },
      self.fixPaymentMethodSubject.map { PPONavigationEvent.fixPaymentMethod },
      self.fix3DSChallengeSubject.map { PPONavigationEvent.fix3DSChallenge },
      self.openSurveySubject.map { PPONavigationEvent.survey },
      self.confirmAddressSubject.map { PPONavigationEvent.confirmAddress },
      self.contactCreatorSubject.map { PPONavigationEvent.contactCreator }
    )
    .subscribe(self.navigationEventSubject)
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

  // TODO: Add any additional properties for routing (MBL-1451)

  func openBackedProjects() {
    self.openBackedProjectsSubject.send(())
  }

  func fixPaymentMethod() {
    self.fixPaymentMethodSubject.send(())
  }

  func fix3DSChallenge() {
    self.fix3DSChallengeSubject.send(())
  }

  func openSurvey() {
    self.openSurveySubject.send(())
  }

  func confirmAddress() {
    self.confirmAddressSubject.send(())
  }

  func contactCreator() {
    self.contactCreatorSubject.send(())
  }

  // MARK: - Outputs

  @Published var bannerViewModel: MessageBannerViewViewModel? = nil
  @Published var results = PPOViewModelPaginator.Results.unloaded

  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> {
    self.navigationEventSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private let paginator: PPOViewModelPaginator

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
  private let shouldSendSampleMessageSubject = PassthroughSubject<(), Never>()
  private let openBackedProjectsSubject = PassthroughSubject<Void, Never>()
  private let fixPaymentMethodSubject = PassthroughSubject<Void, Never>()
  private let fix3DSChallengeSubject = PassthroughSubject<Void, Never>()
  private let openSurveySubject = PassthroughSubject<Void, Never>()
  private let confirmAddressSubject = PassthroughSubject<Void, Never>()
  private let contactCreatorSubject = PassthroughSubject<Void, Never>()

  private var navigationEventSubject = PassthroughSubject<PPONavigationEvent, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 20
  }
}
