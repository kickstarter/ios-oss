import Combine
import Foundation
import KsApi
import Library

protocol PPOContainerViewModelInputs {
  func viewWillAppear()
}

protocol PPOContainerViewModelOutputs {
  var pledgedProjectsOverviewBadge: AnyPublisher<TabBarBadge, Never> { get }
  var activityBadge: AnyPublisher<TabBarBadge, Never> { get }
}

final class PPOContainerViewModel: PPOContainerViewModelInputs, PPOContainerViewModelOutputs {
  init() {
    let sessionStarted = NotificationCenter.default
      .publisher(for: .ksr_sessionStarted)
      .map { _ in () }

    let sessionEnded = NotificationCenter.default
      .publisher(for: .ksr_sessionEnded)
      .map { _ in () }

    let userUpdated = NotificationCenter.default
      .publisher(for: .ksr_userUpdated)
      .map { _ in () }

    let currentUser = Publishers.Merge4(
      self.viewWillAppearSubject,
      userUpdated,
      sessionStarted,
      sessionEnded
    )
    .map { _ in AppEnvironment.current.currentUser }

    currentUser
      .map { user -> TabBarBadge in
        user?.unseenActivityCount
          .flatMap { count -> TabBarBadge in count == 0 ? .none : .count(count) } ?? .none
      }
      .subscribe(self.activityBadgeSubject)
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func viewWillAppear() {
    self.viewWillAppearSubject.send()
  }

  // MARK: - Outputs

  var pledgedProjectsOverviewBadge: AnyPublisher<TabBarBadge, Never> {
    self.pledgedProjectsOverviewBadgeSubject.eraseToAnyPublisher()
  }

  var activityBadge: AnyPublisher<TabBarBadge, Never> {
    self.activityBadgeSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private var viewWillAppearSubject = PassthroughSubject<Void, Never>()
  private var pledgedProjectsOverviewBadgeSubject = CurrentValueSubject<TabBarBadge, Never>(.none)
  private var activityBadgeSubject = CurrentValueSubject<TabBarBadge, Never>(.none)

  private var cancellables: Set<AnyCancellable> = []
}
