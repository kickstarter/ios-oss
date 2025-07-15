import Combine
import Foundation
import KsApi
import ReactiveSwift

public protocol OnboardingViewModelInputs {
  func getNotifiedTapped()
  func allowTrackingTapped()
  func goToNextItemTapped(currentItem: OnboardingItem)
  func goToLoginSignupTapped()
}

public protocol OnboardingViewModelOutputs {
  var onboardingItems: [OnboardingItem] { get }
  var completedGetNotifiedRequest: AnyPublisher<Void, Never> { get }
  var triggerAppTrackingTransparencyPopup: AnyPublisher<Void, Never> { get }
  var goToLoginSignup: AnyPublisher<LoginIntent, Never> { get }
  var currentIndex: Int { get }
}

// MARK: - Combined Type

public typealias OnboardingViewModelType = Equatable & Hashable & Identifiable &
  ObservableObject &
  OnboardingViewModelInputs & OnboardingViewModelOutputs

// MARK: - ViewModel

public final class OnboardingViewModel: OnboardingViewModelType {
  private let useCase: OnboardingUseCaseType
  private var cancellables = Set<AnyCancellable>()
  public var onboardingItems: [OnboardingItem] = []

  @Published public private(set) var currentIndex: Int = 0

  public func hash(into hasher: inout Hasher) {
    hasher.combine(UUID())
  }

  // MARK: - Init

  public init() {
    self.useCase = OnboardingUseCase()

    // Bind onboarding items
    self.useCase.uiOutputs.onboardingItems
      .observe(on: UIScheduler())
      .startWithValues { [weak self] items in
        self?.onboardingItems = items
      }

    // Forward permission triggers
    self.useCase.outputs.completedGetNotifiedRequest
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.completedGetNotifiedRequestSubject.send()
      }

    self.useCase.outputs.triggerAppTrackingTransparencyPopup
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.triggerAppTrackingTransparencyPopupSubject.send()
      }

    self.useCase.uiOutputs.goToLoginSignup
      .observe(on: UIScheduler())
      .observeValues { [weak self] intent in
        self?.goToLoginSignupSubject.send(intent)
      }
  }

  public static func == (lhs: OnboardingViewModel, rhs: OnboardingViewModel) -> Bool {
    lhs.id == rhs.id
  }

  private let completedGetNotifiedRequestSubject = PassthroughSubject<Void, Never>()
  private let triggerAppTrackingTransparencyPopupSubject = PassthroughSubject<Void, Never>()
  private let goToLoginSignupSubject = PassthroughSubject<LoginIntent, Never>()

  // MARK: - Outputs

  public var completedGetNotifiedRequest: AnyPublisher<Void, Never> {
    self.completedGetNotifiedRequestSubject.eraseToAnyPublisher()
  }

  public var triggerAppTrackingTransparencyPopup: AnyPublisher<Void, Never> {
    self.triggerAppTrackingTransparencyPopupSubject.eraseToAnyPublisher()
  }

  public var goToLoginSignup: AnyPublisher<LoginIntent, Never> {
    self.goToLoginSignupSubject.eraseToAnyPublisher()
  }

  // MARK: - Inputs

  public func getNotifiedTapped() {
    self.useCase.uiInputs.getNotifiedTapped()
  }

  public func allowTrackingTapped() {
    self.useCase.uiInputs.allowTrackingTapped()
  }

  public func goToNextItemTapped(currentItem: OnboardingItem) {
    self.useCase.uiInputs.goToNextItemTapped(item: currentItem.type)

    guard let currentIndex = onboardingItems.firstIndex(where: { $0.id == currentItem.id }) else { return }

    let nextIndex = currentIndex + 1
    if self.onboardingItems.indices.contains(nextIndex) {
      self.currentIndex = nextIndex
    }
  }

  public func goToLoginSignupTapped() {
    self.useCase.uiInputs.goToLoginSignupTapped()
  }
}
