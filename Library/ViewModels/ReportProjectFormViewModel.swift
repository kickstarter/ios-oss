import Combine
import Foundation
import KsApi
import ReactiveSwift

public protocol ReportProjectFormViewModelInputs {
  func viewDidLoad()
}

public protocol ReportProjectFormViewModelOutputs {}

public protocol ReportProjectFormViewModelType {
  var inputs: ReportProjectFormViewModelInputs { get }
  var outputs: ReportProjectFormViewModelOutputs { get }
}

public final class ReportProjectFormViewModel: ReportProjectFormViewModelType,
  ReportProjectFormViewModelInputs, ReportProjectFormViewModelOutputs, ObservableObject {
  @Published public var retrievedEmail: String? = nil
  @Published public var saveButtonEnabled: Bool = false
  @Published public var saveButtonLoading: Bool = false
  @Published public var detailsText: String = ""
  @Published public var bannerMessage: MessageBannerViewViewModel? = nil

  @Published public var submitSuccess: Bool = false

  private let viewDidLoadSubject = PassthroughSubject<Bool, Never>()
  private let saveTriggeredSubject = PassthroughSubject<(), Never>()

  private var cancellables = Set<AnyCancellable>()

  public var projectID: String?
  public var projectFlaggingKind: GraphAPI.NonDeprecatedFlaggingKind?

  public init() {
    /// Only enable the save button if the user has entered detail text
    self.$detailsText
      .map { !$0.isEmpty }
      .assign(to: &$saveButtonEnabled)

    /// Load the current user's e-mail on page load
    self.viewDidLoadSubject
      .flatMap { _ in
        AppEnvironment.current
          .apiService
          .fetchGraphUserEmailCombine()
      }
      .compactMap { envelope in
        envelope.me.email
      }
      .catch { _ in
        CurrentValueSubject("")
      }
      .assign(to: &$retrievedEmail)

    /// Submits report on saveTriggered
    self.saveTriggeredSubject
      .compactMap { [weak self] _ in
        self?.createFlaggingInput()
          .handleFailureAndAllowRetry { _ in
            self?.bannerMessage = MessageBannerViewViewModel((
              type: .error,
              message: Strings.Something_went_wrong_please_try_again()
            ))
            self?.saveButtonEnabled = true
            self?.saveButtonLoading = false
          }
      }
      .flatMap { $0 }
      .sink(receiveValue: { [weak self] _ in
        // Submitted successfully

        self?.saveButtonEnabled = false
        self?.saveButtonLoading = false

        self?.bannerMessage = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Your_message_has_been_sent()
        ))
        self?.submitSuccess = true

      })
      .store(in: &self.cancellables)
  }

  private func createFlaggingInput() -> AnyPublisher<EmptyResponseEnvelope, ErrorEnvelope> {
    let input = CreateFlaggingInput(
      contentId: projectID!,
      kind: projectFlaggingKind!,
      details: detailsText,
      clientMutationId: nil
    )

    return AppEnvironment
      .current
      .apiService
      .createFlaggingInputCombine(input: input)
  }

  public func viewDidLoad() {
    self.viewDidLoadSubject.send(true)
  }

  public func didTapSave() {
    self.saveTriggeredSubject.send(())
  }

  public var inputs: ReportProjectFormViewModelInputs {
    return self
  }

  public var outputs: ReportProjectFormViewModelOutputs {
    return self
  }
}
