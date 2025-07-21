import Combine
import Foundation
import KsApi
import ReactiveSwift

public protocol OnboardingViewModelInputs {
  func getNotifiedTapped()
  func allowTrackingTapped()
  func goToLoginSignupTapped()
}

public protocol OnboardingViewModelOutputs {
  var onboardingItems: [OnboardingItem] { get }
  var triggerPushNotificationPermissionDialog: AnyPublisher<Void, Never> { get }
  var triggerAppTrackingTransparencyPopup: AnyPublisher<Void, Never> { get }
  var goToLoginSignup: AnyPublisher<LoginIntent, Never> { get }
}

// MARK: - Combined Type

public typealias OnboardingViewModelType = Equatable & Identifiable &
  ObservableObject &
  OnboardingViewModelInputs & OnboardingViewModelOutputs

// MARK: - ViewModel

public final class OnboardingViewModel: OnboardingViewModelType {
  private let useCase: OnboardingUseCaseType
  private var cancellables = Set<AnyCancellable>()
  public var onboardingItems: [OnboardingItem] = []

  @Published public private(set) var currentIndex: Int = 0

  // MARK: - Init

  public init(with bundle: Bundle = .main) {
    self.useCase = OnboardingUseCase(for: bundle)

    self.useCase.uiOutputs.onboardingItems
      .observe(on: UIScheduler())
      .startWithValues { [weak self] items in
        self?.onboardingItems = items
      }

    self.useCase.outputs.triggerAppTrackingTransparencyDialog
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.triggerAppTrackingTransparencyDialogSubject.send()
      }

    self.useCase.outputs.triggerPushNotificationSystemDialog
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.triggerPushNotificationPermissionDialogSubject.send()
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

  private let triggerPushNotificationPermissionDialogSubject = PassthroughSubject<Void, Never>()
  private let triggerAppTrackingTransparencyDialogSubject = PassthroughSubject<Void, Never>()
  private let goToLoginSignupSubject = PassthroughSubject<LoginIntent, Never>()

  // MARK: - Outputs

  public var triggerPushNotificationPermissionDialog: AnyPublisher<Void, Never> {
    self.triggerPushNotificationPermissionDialogSubject.eraseToAnyPublisher()
  }

  public var triggerAppTrackingTransparencyPopup: AnyPublisher<Void, Never> {
    self.triggerAppTrackingTransparencyDialogSubject.eraseToAnyPublisher()
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

  public func goToLoginSignupTapped() {
    self.useCase.uiInputs.goToLoginSignupTapped()
  }
}
