import Combine
import Foundation
import ReactiveSwift

public protocol ReportProjectFormViewModelInputs {
  func viewDidLoad()
}

public protocol ReportProjectFormViewModelOutputs {
  var userEmail: Signal<String, Never> { get }
}

public protocol ReportProjectFormViewModelType {
  var inputs: ReportProjectFormViewModelInputs { get }
  var outputs: ReportProjectFormViewModelOutputs { get }
}

public final class ReportProjectFormViewModel: ReportProjectFormViewModelType,
                                               ReportProjectFormViewModelInputs,
                                               ReportProjectFormViewModelOutputs, ObservableObject {
  
  public var retrievedEmail: PassthroughSubject<String, Never> = .init()
  
  public init() {
    let userEmailEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current
          .apiService
          .fetchGraphUser(withStoredCards: false)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }
    
    self.userEmail = userEmailEvent.values().map { $0.me.email ?? "" }
    
    _ = self.userEmail
      .observeForUI()
      .observeValues { [weak self] email in
        self?.retrievedEmail.send(email)
      }
  }
  
  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  
  public var userEmail: Signal<String, Never>
  
  public var inputs: ReportProjectFormViewModelInputs {
    return self
  }
  
  public var outputs: ReportProjectFormViewModelOutputs {
    return self
  }
}
