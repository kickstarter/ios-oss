import GraphAPI
import ReactiveSwift
import SwiftUI

public protocol ReportProjectInfoViewModelInputs {
  func viewDidLoad()
}

public protocol ReportProjectInfoViewModelOutputs {}

public protocol ReportProjectInfoViewModelType {
  var inputs: ReportProjectInfoViewModelInputs { get }
  var outputs: ReportProjectInfoViewModelOutputs { get }
}

/// View model for `ReportProjectInfoView`. Fetches flagging options from the API via `FetchFlaggingOptionsUseCase` and exposes them as `@Published` properties for SwiftUI views.
public final class ReportProjectInfoViewModel: ReportProjectInfoViewModelType,
  ReportProjectInfoViewModelInputs,
  ReportProjectInfoViewModelOutputs,
  ObservableObject {
  @Published public var listItems: [ReportProjectInfoListItem] = []
  @Published public var isLoading: Bool = false

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<Void, Never>.pipe()

  public init() {
    let useCase = FetchFlaggingOptionsUseCase(
      contentType: .project,
      initialSignal: self.viewDidLoadSignal
    )

    useCase.outputs.flaggingOptions
      .observe(on: UIScheduler())
      .assign(toCombine: &self.$listItems)

    useCase.outputs.isLoading
      .observe(on: UIScheduler())
      .assign(toCombine: &self.$isLoading)
  }

  // MARK: - Inputs

  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public var inputs: ReportProjectInfoViewModelInputs { return self }
  public var outputs: ReportProjectInfoViewModelOutputs { return self }
}
