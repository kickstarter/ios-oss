import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import WebKit

private struct UpdateData {
  fileprivate let project: Project
  fileprivate let update: Update
}

internal protocol UpdateViewModelInputs {
  /// Call with the project and update given to the controller.
  func configureWith(project: Project, update: Update)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData)
    -> WKNavigationActionPolicy

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol UpdateViewModelOutputs {
  /// Emits when we should go to comments for the update.
  var goToComments: Signal<Update, Never> { get }

  /// Emits when we should go to the project.
  var goToProject: Signal<(Project, RefTag), Never> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<URL, Never> { get }

  /// Emits the title of the controller.
  var title: Signal<String, Never> { get }

  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

internal protocol UpdateViewModelType {
  var inputs: UpdateViewModelInputs { get }
  var outputs: UpdateViewModelOutputs { get }
}

internal final class UpdateViewModel: UpdateViewModelType, UpdateViewModelInputs, UpdateViewModelOutputs {
  internal init() {
    let configurationData = self.configurationDataProperty.signal.skipNil()

    let initialUpdate = configurationData.map { $0.update }

    let project = configurationData.map { $0.project }

    let initialUpdateLoadRequest = initialUpdate
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { URL(string: $0.urls.web.update) }
      .skipNil()
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    let navigationAction = self.policyForNavigationActionProperty.signal.skipNil()

    let anotherUpdateLoadRequest = navigationAction
      .filter {
        $0.navigationType == .linkActivated && Navigation.Project.updateWithRequest($0.request) != nil
      }
      .map { AppEnvironment.current.apiService.preparedRequest(forRequest: $0.request) }

    self.webViewLoadRequest = Signal.merge(
      initialUpdateLoadRequest,
      anotherUpdateLoadRequest
    )

    let anotherUpdate = anotherUpdateLoadRequest
      .map(Navigation.Project.updateWithRequest)
      .skipNil()
      .switchMap { project, update in
        AppEnvironment.current.apiService
          .fetchUpdate(updateId: update, projectParam: project)
          .demoteErrors()
      }

    let currentUpdate = Signal.merge(initialUpdate, anotherUpdate)

    self.title = Signal.combineLatest(currentUpdate, self.viewDidLoadProperty.signal.take(first: 1))
      .map(first)
      .map { Strings.activity_project_update_update_count(update_count: Format.wholeNumber($0.sequence)) }

    self.policyDecisionProperty <~ navigationAction
      .map { action in
        action.navigationType == .other || action.targetFrame?.mainFrame == .some(false)
          ? .allow
          : .cancel
      }

    let externalNavigationAction = navigationAction
      .filter { action in action.navigationType == .linkActivated }
      .filter(isExternalNavigation)

    let internalNavigationAction = navigationAction
      .filter { action in action.navigationType == .linkActivated }
      .filter(isExternalNavigation >>> isFalse)

    let goToComments = currentUpdate
      .takePairWhen(internalNavigationAction)
      .map { update, action -> Update? in
        Navigation.Project.updateCommentsWithRequest(action.request) != nil ? update : nil
      }
      .skipNil()

    let goToProject = internalNavigationAction
      .map { action in (action, Navigation.Project.withRequest(action.request)) }
      .filter(second >>> isNotNil)

    let projectAndRefTag = project
      .takePairWhen(goToProject)
      .map(unpack)
      .switchMap { (project, action, projectParamAndRefTag)
        -> SignalProducer<(WKNavigationActionData, Project, RefTag), Never> in
        guard let (projectParam, refTag) = projectParamAndRefTag else { return .empty }

        let producer: SignalProducer<Project, Never>

        if projectParam == .id(project.id) || projectParam == .slug(project.slug) {
          producer = SignalProducer(value: project)
        } else {
          producer = AppEnvironment.current.apiService.fetchProject(param: projectParam)
            .demoteErrors()
        }

        return producer.map { (action, $0, refTag ?? RefTag.update) }
      }

    self.goToComments = goToComments
    self.goToProject = projectAndRefTag.filter { _, project, _ in project.displayPrelaunch != .some(true) }
      .map { _, project, refTag in (project, refTag) }

    let goToPrelaunchPage = projectAndRefTag
      .filter { _, project, _ in project.displayPrelaunch == true }
      .map(first)

    self.goToSafariBrowser = Signal.merge(externalNavigationAction, goToPrelaunchPage)
      .map { action in action.request.url }
      .skipNil()
  }

  fileprivate let configurationDataProperty = MutableProperty<UpdateData?>(nil)
  internal func configureWith(project: Project, update: Update) {
    self.configurationDataProperty.value = UpdateData(project: project, update: update)
  }

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.allow)
  internal func decidePolicyFor(navigationAction: WKNavigationActionData)
    -> WKNavigationActionPolicy {
    self.policyForNavigationActionProperty.value = navigationAction
    return self.policyDecisionProperty.value
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let goToComments: Signal<Update, Never>
  internal let goToProject: Signal<(Project, RefTag), Never>
  internal let goToSafariBrowser: Signal<URL, Never>
  internal let title: Signal<String, Never>
  internal let webViewLoadRequest: Signal<URLRequest, Never>

  internal var inputs: UpdateViewModelInputs { return self }
  internal var outputs: UpdateViewModelOutputs { return self }
}

func isExternalNavigation(_ action: WKNavigationActionData) -> Bool {
  return ([
    Navigation.Project.withRequest(action.request),
    Navigation.Project.updateWithRequest(action.request),
    Navigation.Project.updateCommentsWithRequest(action.request)
  ] as [Any?]).compactMap { $0 }.isEmpty
}
