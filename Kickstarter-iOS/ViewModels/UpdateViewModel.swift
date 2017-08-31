import Argo
import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

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
  var goToComments: Signal<Update, NoError> { get }

  /// Emits when we should go to the project.
  var goToProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<URL, NoError> { get }

  /// Emits the title of the controller.
  var title: Signal<String, NoError> { get }

  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<URLRequest, NoError> { get }
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
        return AppEnvironment.current.apiService
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

    let possiblyGoToComments = currentUpdate
      .takePairWhen(navigationAction)
      .map { update, action -> Update? in
        if action.navigationType == .linkActivated
          && Navigation.Project.updateCommentsWithRequest(action.request) != nil {
          return update
        }
        return nil
    }

    self.goToComments = possiblyGoToComments.skipNil()

    let possiblyGoToProject = navigationAction
      .map { action in
        action.navigationType == .linkActivated
          ? Navigation.Project.withRequest(action.request)
          : nil
    }

    self.goToProject = project
      .takePairWhen(possiblyGoToProject)
      .switchMap { (project, projectParamAndRefTag) -> SignalProducer<(Project, RefTag), NoError> in

        guard let (projectParam, refTag) = projectParamAndRefTag else { return .empty }

        let producer: SignalProducer<Project, NoError>

        if projectParam == .id(project.id) || projectParam == .slug(project.slug) {
          producer = SignalProducer(value: project)
        } else {
          producer = AppEnvironment.current.apiService.fetchProject(param: projectParam)
            .demoteErrors()
        }

        return producer.map { ($0, refTag ?? RefTag.update) }
      }

    self.goToSafariBrowser = Signal.zip(navigationAction, possiblyGoToProject, possiblyGoToComments)
      .filter { action, goToProject, goToComments in
        Navigation.Project.updateWithRequest(action.request) == nil
          && action.navigationType == .linkActivated
          && goToProject == nil
          && goToComments == nil
      }
      .map { action, _, _ in action.request.url }
      .skipNil()

    project
      .takeWhen(self.goToSafariBrowser)
      .observeValues {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectUpdate)
    }
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

  fileprivate let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  internal let goToComments: Signal<Update, NoError>
  internal let goToProject: Signal<(Project, RefTag), NoError>
  internal let goToSafariBrowser: Signal<URL, NoError>
  internal let title: Signal<String, NoError>
  internal let webViewLoadRequest: Signal<URLRequest, NoError>

  internal var inputs: UpdateViewModelInputs { return self }
  internal var outputs: UpdateViewModelOutputs { return self }
}
