import KsApi
import Prelude
import ReactiveSwift
import WebKit

public protocol ProjectDescriptionViewModelInputs {
  /// Call with the project and reftag given to the view.
  func configureWith(value: (Project, RefTag?))

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData)

  /// Call when the pledge CTA button is tapped.
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the webview fails to navigate.
  func webViewDidFailProvisionalNavigation(withError error: Error)

  /// Call when the webview finishes navigating.
  func webViewDidFinishNavigation()

  /// Call when the webview starts navigating to a page.
  func webViewDidStartProvisionalNavigation()
}

public protocol ProjectDescriptionViewModelOutputs {
  /// Emits PledgeCTAContainerViewData to configure the PledgeCTAContainerView
  var configurePledgeCTAContainerView: Signal<PledgeCTAContainerViewData, Never> { get }

  /// Can be returned from the web view's policy decision delegate method.
  var decidedPolicyForNavigationAction: WKNavigationActionPolicy { get }

  /// Emits when we should go back to the project.
  var goBackToProject: Signal<(), Never> { get }

  /// Emits when we should navigate to the message dialog.
  var goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), Never> { get }

  /// Emits when we should navigate to the rewards
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<URL, Never> { get }

  /// Emits when a web request is loading.
  var isLoading: Signal<Bool, Never> { get }

  /// Emits a url request that should be loaded into the webview.
  var loadWebViewRequest: Signal<URLRequest, Never> { get }

  /// Emits whether the pledgeCTAContainerView is hidden.
  var pledgeCTAContainerViewIsHidden: Signal<Bool, Never> { get }

  /// Emits when an error should be displayed.
  var showErrorAlert: Signal<Error, Never> { get }
}

public protocol ProjectDescriptionViewModelType {
  var inputs: ProjectDescriptionViewModelInputs { get }
  var outputs: ProjectDescriptionViewModelOutputs { get }
}

public final class ProjectDescriptionViewModel: ProjectDescriptionViewModelType,
  ProjectDescriptionViewModelInputs, ProjectDescriptionViewModelOutputs {
  public init() {
    let projectAndRefTag = Signal.combineLatest(
      self.projectAndRefTagProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let project = projectAndRefTag.map(first)

    let navigationAction = self.policyForNavigationActionProperty.signal.skipNil()
    let navigationActionLink = navigationAction
      .filter { $0.navigationType == .linkActivated }
    let navigation = navigationActionLink
      .map { Navigation.match($0.request) }

    let projectDescriptionRequest = project
      .map {
        URL(string: $0.urls.web.project)?.appendingPathComponent("description")
      }
      .skipNil()

    self.isLoading = Signal
      .merge(
        self.viewDidLoadProperty.signal.map(const(true)),
        self.webViewDidStartProvisionalNavigationProperty.signal.map(const(true)),
        self.webViewDidFinishNavigationProperty.signal.map(const(false))
      )
      .skipRepeats()

    self.loadWebViewRequest = projectDescriptionRequest
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    self.policyDecisionProperty <~ navigationAction
      .map { action in allowed(navigationAction: action) ? .allow : .cancel }

    let possiblyGoToMessageDialog = Signal.combineLatest(project, navigation)
      .map { (project, navigation) -> (MessageSubject, Koala.MessageDialogContext)? in
        guard navigation.map(isMessageCreator(navigation:)) == true else { return nil }
        return (MessageSubject.project(project), Koala.MessageDialogContext.projectPage)
      }

    self.goToMessageDialog = possiblyGoToMessageDialog.skipNil()

    let possiblyGoBackToProject = Signal.combineLatest(project, navigation)
      .map { (project, navigation) -> Project? in
        guard
          case let (.project(param, .root, _))? = navigation,
          String(project.id) == param.slug || project.slug == param.slug
        else { return nil }

        return project
      }

    self.showErrorAlert = self.webViewDidFailProvisionalNavigationProperty.signal.skipNil()

    self.goBackToProject = Signal.merge(
      possiblyGoBackToProject.skipNil().ignoreValues(),
      self.showErrorAlert.ignoreValues()
    )

    self.goToSafariBrowser = Signal.zip(
      navigationActionLink, possiblyGoToMessageDialog, possiblyGoBackToProject
    )
    .filter { $1 == nil && $2 == nil }
    .filter { navigationAction, _, _ in navigationAction.navigationType == .linkActivated }
    .map { navigationAction, _, _ in navigationAction.request.url }
    .skipNil()

    self.pledgeCTAContainerViewIsHidden = projectAndRefTag
      .map(shouldShowPledgeButton)
      .negate()

    self.configurePledgeCTAContainerView = projectAndRefTag
      .combineLatest(with: self.pledgeCTAContainerViewIsHidden)
      .filter(second >>> isFalse)
      .map(first)
      .map(Either.left)
      .map { ($0, false, .projectDescription) }

    self.goToRewards = projectAndRefTag
      .takeWhen(self.pledgeCTAButtonTappedProperty.signal)

    projectAndRefTag
      .takeWhen(self.pledgeCTAButtonTappedProperty.signal)
      .observeValues { project, refTag in
        let cookieRefTag = cookieRefTagFor(project: project) ?? refTag
        let optimizelyProps = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala.trackCampaignDetailsPledgeButtonClicked(
          project: project,
          location: .campaign,
          refTag: refTag,
          cookieRefTag: cookieRefTag,
          optimizelyProperties: optimizelyProps
        )
        AppEnvironment.current.optimizelyClient?.track(eventName: "Campaign Details Pledge Button Clicked")
      }

    project
      .takeWhen(self.goToSafariBrowser)
      .observeValues {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectDescription)
      }
  }

  private let pledgeCTAButtonTappedProperty = MutableProperty<PledgeStateCTAType?>(nil)
  public func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.pledgeCTAButtonTappedProperty.value = state
  }

  fileprivate let projectAndRefTagProperty = MutableProperty<(Project, RefTag?)?>(nil)
  public func configureWith(value: (Project, RefTag?)) {
    self.projectAndRefTagProperty.value = value
  }

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  public func decidePolicyFor(navigationAction: WKNavigationActionData) {
    self.policyForNavigationActionProperty.value = navigationAction
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.allow)
  public var decidedPolicyForNavigationAction: WKNavigationActionPolicy {
    return self.policyDecisionProperty.value
  }

  fileprivate let webViewDidFailProvisionalNavigationProperty = MutableProperty(Error?.none)
  public func webViewDidFailProvisionalNavigation(withError error: Error) {
    self.webViewDidFailProvisionalNavigationProperty.value = error
  }

  fileprivate let webViewDidFinishNavigationProperty = MutableProperty(())
  public func webViewDidFinishNavigation() {
    self.webViewDidFinishNavigationProperty.value = ()
  }

  fileprivate let webViewDidStartProvisionalNavigationProperty = MutableProperty(())
  public func webViewDidStartProvisionalNavigation() {
    self.webViewDidStartProvisionalNavigationProperty.value = ()
  }

  public let configurePledgeCTAContainerView: Signal<PledgeCTAContainerViewData, Never>
  public let goBackToProject: Signal<(), Never>
  public let goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), Never>
  public let goToRewards: Signal<(Project, RefTag?), Never>
  public let goToSafariBrowser: Signal<URL, Never>
  public let isLoading: Signal<Bool, Never>
  public let loadWebViewRequest: Signal<URLRequest, Never>
  public let pledgeCTAContainerViewIsHidden: Signal<Bool, Never>
  public let showErrorAlert: Signal<Error, Never>

  public var inputs: ProjectDescriptionViewModelInputs { return self }
  public var outputs: ProjectDescriptionViewModelOutputs { return self }
}

private func isMessageCreator(navigation: Navigation) -> Bool {
  guard case .project(_, .messageCreator, _) = navigation else { return false }
  return true
}

private func allowed(navigationAction action: WKNavigationActionData) -> Bool {
  return action.request.url?.path.contains("/description") == .some(true)
    || action.targetFrame?.mainFrame == .some(false)
}

private func shouldShowPledgeButton(project: Project, refTag: RefTag?) -> Bool {
  let isLive = project.state == .live
  let notBacking = project.personalization.backing == nil
  let isVariant2 = OptimizelyExperiment
    .projectCampaignExperiment(project: project, refTag: refTag) == .variant2
  let isNotCreator = currentUserIsCreator(of: project) == false

  return [isLive, notBacking, isVariant2, isNotCreator].allSatisfy(isTrue)
}
