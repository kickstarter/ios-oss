import KsApi
import MessageUI
import Prelude
import ReactiveSwift
import Result
import WebKit

public protocol ProjectUpdatesViewModelInputs {

  /// Call to set whether Mail can be composed.
  func canSendEmail(_ canSend: Bool)

  /// Call with the project given to the view.
  func configureWith(project: Project)

  /// Call with the navigation action given to the webview's delegate method. Returns the policy that can
  /// be returned from the delegate method.
  func decidePolicy(forNavigationAction action: WKNavigationActionData) -> WKNavigationActionPolicy

  /// Call when mail compose view controller has closed with a result.
  func mailComposeCompletion(result: MFMailComposeResult)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when webview did finish navigation.
  func webViewDidFinishNavigation()

  /// Call when webview did start navigation.
  func webViewDidStartProvisionalNavigation()
}

public protocol ProjectUpdatesViewModelOutputs {
  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<URL, NoError> { get }

  /// Emits with the project and update when we should go to the update.
  var goToUpdate: Signal<(Project, Update), NoError> { get }

  /// Emits with the project when we should go to the update comments.
  var goToUpdateComments: Signal<Update, NoError> { get }

  /// Emits when the webview content is loading.
  var isActivityIndicatorHidden: Signal<Bool, NoError> { get }

  /// Emits when app should make phone call.
  var makePhoneCall: Signal<URL, NoError> { get }

  /// Emits to show a MFMailComposeViewController.
  var showMailCompose: Signal<String, NoError> { get }

  /// Emits to show an alert when device can not send emails.
  var showNoEmailError: Signal<UIAlertController, NoError> { get }

  /// Emits a request that should be loaded into the web view.
  var webViewLoadRequest: Signal<URLRequest, NoError> { get }
}

public protocol ProjectUpdatesViewModelType {
  var inputs: ProjectUpdatesViewModelInputs { get }
  var outputs: ProjectUpdatesViewModelOutputs { get }
}

public final class ProjectUpdatesViewModel: ProjectUpdatesViewModelType, ProjectUpdatesViewModelInputs,
ProjectUpdatesViewModelOutputs {

  public init() {
    let navigationAction = self.navigationAction.signal.skipNil()

    let canMakePhoneCall = self.canMakePhoneCallProperty.signal.skipNil()

    let canSendEmail = self.canSendEmailProperty.signal.skipNil()

    let project = Signal.combineLatest(self.projectProperty.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let initialUpdatesIndexLoadRequest = project.map { URL(string: $0.urls.web.updates ?? "") }.skipNil()

    let anotherIndexRequest = navigationAction
      .filter { $0.navigationType == .linkActivated && isUpdatesRequest(request: $0.request) }
      .map { $0.request.url }
      .skipNil()

    let goToCommentsRequest = navigationAction
      .filter { isGoToCommentsRequest(request: $0.request) }
      .map { projectUpdateParams(fromRequest: $0.request) }
      .skipNil()

    let goToUpdateRequest = navigationAction
      .filter { isGoToUpdateRequest(request: $0.request) }
      .map { projectUpdateParams(fromRequest: $0.request) }
      .skipNil()
      .switchMap { projectParam, updateId in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: projectParam)
          .demoteErrors()
      }

    self.decidedPolicy <~ navigationAction
      .map { action in
        action.navigationType == .other || action.targetFrame?.mainFrame == .some(false)
          ? .allow
          : .cancel
    }

    self.goToSafariBrowser = navigationAction
      .filter {
        $0.navigationType == .linkActivated &&
        !isGoToCommentsRequest(request: $0.request) &&
        !isGoToUpdateRequest(request: $0.request) &&
        !isUpdatesRequest(request: $0.request) &&
        !isPhoneLink(action: $0) &&
        !isEmailLink(action: $0)
      }
      .map { $0.request.url }
      .skipNil()

    let emailLink = navigationAction
      .filter { (action: WKNavigationActionData) in
        action.navigationType == .linkActivated &&
          !isGoToCommentsRequest(request: action.request) &&
          !isGoToUpdateRequest(request: action.request) &&
          !isUpdatesRequest(request: action.request) &&
          isEmailLink(action: action)
      }
      .map(formattedEmailAddress)

    let phoneNumberLink = navigationAction
      .filter { (action: WKNavigationActionData) in
        action.navigationType == .linkActivated &&
          !isGoToCommentsRequest(request: action.request) &&
          !isGoToUpdateRequest(request: action.request) &&
          !isUpdatesRequest(request: action.request) &&
          isPhoneLink(action: action)
      }
      .map { $0.request.url }
      .skipNil()

    self.makePhoneCall = canMakePhoneCall
      .takePairWhen(phoneNumberLink)
      .map { $0.1 }

    self.showMailCompose = canSendEmail
      .takePairWhen(emailLink)
      .filter { canSend, _ in canSend == true }
      .map { $0.1 }

    self.showNoEmailError = canSendEmail
      .takePairWhen(emailLink)
      .filter { canSend, _ in !canSend }
      .map { _ in noEmailError() }

    self.goToUpdate = project.takePairWhen(goToUpdateRequest)

    self.goToUpdateComments = goToCommentsRequest
      .switchMap { projectParam, updateId in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: projectParam)
        .demoteErrors()
    }

    self.isActivityIndicatorHidden = Signal.merge(
      self.webViewDidFinishNavigationProperty.signal.mapConst(true),
      self.webViewDidStartProvisionalNavigationProperty.signal.mapConst(false)
    )

    self.webViewLoadRequest = Signal.merge(initialUpdatesIndexLoadRequest, anotherIndexRequest)
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    project
      .takeWhen(self.goToSafariBrowser)
      .observeValues {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectUpdates)
    }
  }

  fileprivate let canSendEmailProperty = MutableProperty<Bool?>(nil)
  public func canSendEmail(_ canSend: Bool) {
    self.canSendEmailProperty.value = canSend
  }

  fileprivate let mailComposeCompletionProperty = MutableProperty<MFMailComposeResult?>(nil)
  public func mailComposeCompletion(result: MFMailComposeResult) {
    self.mailComposeCompletionProperty.value = result
  }

  fileprivate let navigationAction = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let decidedPolicy = MutableProperty(WKNavigationActionPolicy.cancel)
  public func decidePolicy(forNavigationAction action: WKNavigationActionData)
          -> WKNavigationActionPolicy {
    self.navigationAction.value = action
    return self.decidedPolicy.value
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let canMakePhoneCallProperty = MutableProperty<Bool?>(nil)
  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
    self.canMakePhoneCallProperty.value = canMakePhoneCall()
  }

  fileprivate let webViewDidFinishNavigationProperty = MutableProperty(())
  public func webViewDidFinishNavigation() {
    self.webViewDidFinishNavigationProperty.value = ()
  }

  fileprivate let webViewDidStartProvisionalNavigationProperty = MutableProperty(())
  public func webViewDidStartProvisionalNavigation() {
    self.webViewDidStartProvisionalNavigationProperty.value = ()
  }

  public let goToSafariBrowser: Signal<URL, NoError>
  public let goToUpdate: Signal<(Project, Update), NoError>
  public let goToUpdateComments: Signal<Update, NoError>
  public let isActivityIndicatorHidden: Signal<Bool, NoError>
  public let makePhoneCall: Signal<URL, NoError>
  public let showMailCompose: Signal<String, NoError>
  public let showNoEmailError: Signal<UIAlertController, NoError>
  public let webViewLoadRequest: Signal<URLRequest, NoError>

  public var inputs: ProjectUpdatesViewModelInputs { return self }
  public var outputs: ProjectUpdatesViewModelOutputs { return self }
}

private func canMakePhoneCall() -> Bool {
  guard let url = URL(string: "tel://") else {
    return false
  }
  return UIApplication.shared.canOpenURL(url)
}

// Returns project and update params for update and comments requests.
private func projectUpdateParams(fromRequest request: URLRequest) -> (projectParam: Param, updateId: Int)? {
  guard let nav = Navigation.match(request) else { return nil }
  switch nav {
  case .project(_, .update(_, .comments), _):
    return Navigation.Project.updateCommentsWithRequest(request)
  case .project(_, .update(_, .root), _):
    return Navigation.Project.updateWithRequest(request)
  default:
    return nil
  }
}

private func formattedEmailAddress(_ action: WKNavigationActionData) -> String {
  return action.request.url?.absoluteString.replacingOccurrences(of: "mailto:", with: "") ?? ""
}

private func isEmailLink(action: WKNavigationActionData) -> Bool {
  return action.request.url?.scheme == "mailto"
}

private func isGoToCommentsRequest(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .update(_, .comments), _) = nav { return true }
  return false
}

private func isGoToUpdateRequest(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .update(_, .root), _) = nav { return true }
  return false
}

private func isPhoneLink(action: WKNavigationActionData) -> Bool {
  return action.request.url?.scheme == "tel" ? true : false
}

private func isUpdatesRequest(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .updates, _) = nav { return true }
  return false
}

private func noEmailError() -> UIAlertController {
  let alertController = UIAlertController(
    title: Strings.support_email_noemail_title(),
    message: Strings.support_email_noemail_message(),
    preferredStyle: .alert
  )
  alertController.addAction(
    UIAlertAction(
      title: Strings.general_alert_buttons_ok(),
      style: .cancel,
      handler: nil
    )
  )

  return alertController
}
