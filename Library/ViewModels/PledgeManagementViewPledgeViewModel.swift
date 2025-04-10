import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift

internal protocol PledgeManagementViewPledgeViewModelInputs {
  /// Configure this webview using a `Project`.
  func configureWith(project: Project)

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol PledgeManagementViewPledgeViewModelOutputs {
  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

internal protocol PledgeManagementViewPledgeViewModelType {
  var inputs: PledgeManagementViewPledgeViewModelInputs { get }
  var outputs: PledgeManagementViewPledgeViewModelOutputs { get }
}

internal final class PledgeManagementViewPledgeViewModel: PledgeManagementViewPledgeViewModelType,
  PledgeManagementViewPledgeViewModelInputs, PledgeManagementViewPledgeViewModelOutputs {
  internal init() {
    let project = Signal.combineLatest(self.projectProperty.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)

    self.webViewLoadRequest = project.map(getProjectBackingDetailsURL(with:))
    .skipNil()
    .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }
  }

  internal var inputs: PledgeManagementViewPledgeViewModelInputs { return self }
  internal var outputs: PledgeManagementViewPledgeViewModelOutputs { return self }

  internal let webViewLoadRequest: Signal<URLRequest, Never>

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}
