import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import WebKit

public protocol SurveyResponseViewModelInputs {
  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call to configure with a survey response.
  func configureWith(surveyResponse: SurveyResponse)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData) -> WKNavigationActionPolicy

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol SurveyResponseViewModelOutputs {
  /// Emits when the view controller should be dismissed.
  var dismissViewController: Signal<Void, Never> { get }

  /// Emits a project and ref tag that should be used to present a project controller.
  var goToProject: Signal<(Param, RefTag?), Never> { get }

  /// Set the navigation item's title.
  var title: Signal<String, Never> { get }

  /// Emits a request that should be loaded by the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

public protocol SurveyResponseViewModelType: SurveyResponseViewModelInputs, SurveyResponseViewModelOutputs {
  var inputs: SurveyResponseViewModelInputs { get }
  var outputs: SurveyResponseViewModelOutputs { get }
}

public final class SurveyResponseViewModel: SurveyResponseViewModelType {
  public init() {
    let surveyResponse = Signal.combineLatest(
      self.surveyResponseProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let initialRequest = surveyResponse
      .map { surveyResponse -> URLRequest? in
        guard let url = URL(string: surveyResponse.urls.web.survey) else { return nil }
        return URLRequest(url: url)
      }
      .skipNil()

    let requestAndNavigationType = self.policyForNavigationActionProperty.signal.skipNil()
      .map { action in (action.request, action.navigationType) }

    let surveyPostRequest = requestAndNavigationType
      .filter { request, navigationType in
        isUnpreparedSurvey(request: request) && navigationType == .formSubmitted
      }
      .map { request, _ in request }

    self.dismissViewController = self.closeButtonTappedProperty.signal

    self.goToProject = requestAndNavigationType
      .map { request, _ -> (Param, RefTag?)? in
        if case let (.project(param, .root, refInfo))? = Navigation.match(request) {
          return (param, refInfo?.refTag)
        }
        return nil
      }
      .skipNil()

    self.policyDecisionProperty <~ requestAndNavigationType
      .map { request, _ in
        if !AppEnvironment.current.apiService.isPrepared(request: request) {
          return false
        }

        return isSurvey(request: request)
      }
      .map { $0 ? .allow : .cancel }

    self.title = self.viewDidLoadProperty.signal
      .mapConst(Strings.Survey())

    self.webViewLoadRequest = Signal.merge(
      initialRequest,
      surveyPostRequest
    )
    .map { request in AppEnvironment.current.apiService.preparedRequest(forRequest: request) }
  }

  fileprivate let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() { self.closeButtonTappedProperty.value = () }

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.allow)
  public func decidePolicyFor(navigationAction: WKNavigationActionData) -> WKNavigationActionPolicy {
    self.policyForNavigationActionProperty.value = navigationAction
    return self.policyDecisionProperty.value
  }

  fileprivate let surveyResponseProperty = MutableProperty<SurveyResponse?>(nil)
  public func configureWith(surveyResponse: SurveyResponse) {
    self.surveyResponseProperty.value = surveyResponse
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let dismissViewController: Signal<Void, Never>
  public let goToProject: Signal<(Param, RefTag?), Never>
  public let title: Signal<String, Never>
  public let webViewLoadRequest: Signal<URLRequest, Never>

  public var inputs: SurveyResponseViewModelInputs { return self }
  public var outputs: SurveyResponseViewModelOutputs { return self }
}

private func isUnpreparedSurvey(request: URLRequest) -> Bool {
  guard !AppEnvironment.current.apiService.isPrepared(request: request) else { return false }
  return isSurvey(request: request)
}

private func isSurvey(request: URLRequest) -> Bool {
  guard case (.project(_, .survey, _))? = Navigation.match(request) else { return false }
  return true
}
