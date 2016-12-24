import KsApi
import Library
import ReactiveSwift
import Result

internal protocol UpdatePreviewViewModelInputs {
  /// Call with the update draft.
  func configureWith(draft: UpdateDraft)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData)
    -> WKNavigationActionPolicy

  /// Call when the publish button is tapped.
  func publishButtonTapped()

  /// Call when the publish confirmation is tapped.
  func publishConfirmationButtonTapped()

  /// Call when the publish cancel is tapped.
  func publishCancelButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol UpdatePreviewViewModelOutputs {
  /// Emits when publishing succeeds.
  var goToUpdate: Signal<(Project, Update), NoError> { get }

  /// Emits when the view should show a publish confirmation alert with detail message.
  var showPublishConfirmation: Signal<String, NoError> { get }

  /// Emits when publishing fails.
  var showPublishFailure: Signal<(), NoError> { get }

  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

internal protocol UpdatePreviewViewModelType {
  var inputs: UpdatePreviewViewModelInputs { get }
  var outputs: UpdatePreviewViewModelOutputs { get }
}

internal final class UpdatePreviewViewModel: UpdatePreviewViewModelInputs,
  UpdatePreviewViewModelOutputs, UpdatePreviewViewModelType {

  // swiftlint:disable function_body_length
  internal init() {
    let draft = self.draftProperty.signal.skipNil()

    let initialRequest = draft
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { AppEnvironment.current.apiService.previewUrl(forDraft: $0) }
      .skipNil()
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    let redirectRequest = self.policyForNavigationActionProperty.signal.skipNil()
      .map { $0.request }
      .filter {
        !AppEnvironment.current.apiService.isPrepared(request: $0)
          && Navigation.Project.updateWithRequest($0) != nil
      }
      .map { AppEnvironment.current.apiService.preparedRequest(forRequest: $0) }

    self.webViewLoadRequest = Signal.merge(initialRequest, redirectRequest)

    self.policyDecisionProperty <~ self.policyForNavigationActionProperty.signal.skipNil()
      .map { action in
        action.navigationType == .Other || action.targetFrame?.mainFrame == .Some(false)
          ? .Allow
          : .Cancel
    }

    let projectEvent = draft
      .switchMap {
        AppEnvironment.current.apiService.fetchProject(param: .id($0.update.projectId))
          .materialize()
    }
    let project = projectEvent
      .values()

    self.showPublishConfirmation = project
      .map {
        // swiftlint:disable line_length
        Strings
          .dashboard_post_update_preview_confirmation_alert_this_will_notify_backers_that_a_new_update_is_available(backer_count: $0.stats.backersCount)
        // swiftlint:enable line_length
      }
      .takeWhen(self.publishButtonTappedProperty.signal)

    let publishEvent = draft
      .takeWhen(self.publishConfirmationButtonTappedProperty.signal)
      .switchMap {
        AppEnvironment.current.apiService.publish(draft: $0)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }
    let update = publishEvent
      .values()

    self.goToUpdate = combineLatest(project, update)
    self.showPublishFailure = publishEvent
      .errors()
      .ignoreValues()

    // Koala

    project
      .takeWhen(self.publishButtonTappedProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackTriggeredPublishConfirmationModal(forProject: $0)
    }

    project
      .takeWhen(self.publishConfirmationButtonTappedProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackConfirmedPublishUpdate(forProject: $0)
    }

    project
      .takeWhen(self.publishCancelButtonTappedProperty.signal)
      .observeValues {
        AppEnvironment.current.koala.trackCanceledPublishUpdate(forProject: $0)
    }

    self.goToUpdate
      .observeValues {
        AppEnvironment.current.koala.trackPublishedUpdate(forProject: $0, isPublic: $1.isPublic)
    }
  }
  // swiftlint:enable function_body_length

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.Allow)
  internal func decidePolicyFor(navigationAction: WKNavigationActionData)
    -> WKNavigationActionPolicy {
      self.policyForNavigationActionProperty.value = navigationAction
      return self.policyDecisionProperty.value
  }

  fileprivate let publishButtonTappedProperty = MutableProperty()
  internal func publishButtonTapped() {
    self.publishButtonTappedProperty.value = ()
  }

  fileprivate let publishCancelButtonTappedProperty = MutableProperty()
  internal func publishCancelButtonTapped() {
    self.publishCancelButtonTappedProperty.value = ()
  }

  fileprivate let publishConfirmationButtonTappedProperty = MutableProperty()
  internal func publishConfirmationButtonTapped() {
    self.publishConfirmationButtonTappedProperty.value = ()
  }

  fileprivate let draftProperty = MutableProperty<UpdateDraft?>(nil)
  internal func configureWith(draft: UpdateDraft) {
    self.draftProperty.value = draft
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  let goToUpdate: Signal<(Project, Update), NoError>
  let showPublishConfirmation: Signal<String, NoError>
  let showPublishFailure: Signal<(), NoError>
  let webViewLoadRequest: Signal<NSURLRequest, NoError>

  internal var inputs: UpdatePreviewViewModelInputs { return self }
  internal var outputs: UpdatePreviewViewModelOutputs { return self }
}
