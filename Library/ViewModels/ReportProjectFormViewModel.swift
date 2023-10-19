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
  @Published public var detailsText: String = ""
  @Published public var saveTriggered: Bool = false
  @Published public var bannerMessage: MessageBannerViewViewModel? = nil

  @Published public var submitSuccess: Bool = false

  private let viewDidLoadSubject = PassthroughSubject<Bool, Never>()

  private var cancellables = Set<AnyCancellable>()

  public let projectID: String
  public let projectURL: String
  public let projectFlaggingKind: GraphAPI.FlaggingKind

  public init(projectID: String,
              projectURL: String,
              projectFlaggingKind: GraphAPI.FlaggingKind) {
    self.projectID = projectID
    self.projectURL = projectURL
    self.projectFlaggingKind = projectFlaggingKind

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
    self.$saveTriggered
      .filter { $0 } // only save if saveTriggered is true
      .compactMap { [weak self] _ in
        self?.createFlaggingInput()
      }
      .flatMap { $0 }
      .sink { [weak self] _ in
        // An error happens

        self?.saveTriggered = false
        self?.bannerMessage = MessageBannerViewViewModel((
          type: .error,
          message: Strings.Something_went_wrong_please_try_again()
        ))
        self?.saveButtonEnabled = true

      } receiveValue: { [weak self] _ in
        // Submitted successfully

        self?.saveTriggered = false
        self?.saveButtonEnabled = false
        self?.bannerMessage = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Your_message_has_been_sent()
        ))
        self?.submitSuccess = true
      }
      .store(in: &self.cancellables)
  }

  private func createFlaggingInput() -> AnyPublisher<EmptyResponseEnvelope, ErrorEnvelope> {
    let input = CreateFlaggingInput(
      contentId: projectID,
      kind: projectFlaggingKind,
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

  public var inputs: ReportProjectFormViewModelInputs {
    return self
  }

  public var outputs: ReportProjectFormViewModelOutputs {
    return self
  }
}
