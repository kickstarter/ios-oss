import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SurveyResponseViewModelInputs {
  /// Call when the alert OK button is tapped.
  func alertButtonTapped()

  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call to configure with a survey response.
  func configureWith(surveyResponse: SurveyResponse)

  /// Call when the webview decides whether to load a request.
  func shouldStartLoad(withRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol SurveyResponseViewModelOutputs {
  /// Emits when the view controller should be dismissed.
  var dismissViewController: Signal<Void, NoError> { get }

  /// Emits a project and ref tag that should be used to present a project controller.
  var goToProject: Signal<(Param, RefTag?), NoError> { get }

  /// Emits when an alert should be shown.
  var showAlert: Signal<String, NoError> { get }

  /// Set the navigation item's title.
  var title: Signal<String, NoError> { get }

  /// Emits a request that should be loaded by the webview.
  var webViewLoadRequest: Signal<URLRequest, NoError> { get }
}

public protocol SurveyResponseViewModelType: SurveyResponseViewModelInputs, SurveyResponseViewModelOutputs {
  var inputs: SurveyResponseViewModelInputs { get }
  var outputs: SurveyResponseViewModelOutputs { get }
}

public final class SurveyResponseViewModel: SurveyResponseViewModelType {

    public init() {
    let initialRequest = self.surveyResponseProperty.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { surveyResponse -> URLRequest? in
        guard let url = URL(string: surveyResponse.urls.web.survey) else { return nil }
        return URLRequest(url: url)
      }
      .skipNil()

    let postRequest = self.shouldStartLoadProperty.signal.skipNil()
      .filter { request, navigationType in
        isUnpreparedSurvey(request: request) && navigationType == .formSubmitted
      }
      .map { request, _ in request }

    let redirectAfterPostRequest = self.shouldStartLoadProperty.signal.skipNil()
      .filter { request, navigationType in
        isUnpreparedSurvey(request: request) && navigationType == .other
      }
      .map { request, _ in request }

    self.dismissViewController = Signal.merge(
      self.alertButtonTappedProperty.signal,
      self.closeButtonTappedProperty.signal
    )

    self.goToProject = self.shouldStartLoadProperty.signal.skipNil()
      .map { request, _ -> (Param, RefTag?)? in
        if case let (.project(param, .root, refTag))? = Navigation.match(request) {
          return (param, refTag)
        }
        return nil
      }
      .skipNil()

    self.shouldStartLoadResponseProperty <~ self.shouldStartLoadProperty.signal.skipNil()
      .map { request, _ in
        if !AppEnvironment.current.apiService.isPrepared(request: request) {
          return false
        }

        return isSurvey(request: request)
      }

    self.showAlert = redirectAfterPostRequest
      .mapConst(Strings.Got_it_your_survey_response_has_been_submitted())

    self.title = self.viewDidLoadProperty.signal
      .mapConst(Strings.Survey())

    self.webViewLoadRequest = Signal.merge(
      initialRequest,
      postRequest
      )
      .map { request in AppEnvironment.current.apiService.preparedRequest(forRequest: request) }
  }
  // swiftlint:enable function_body_length

  fileprivate let alertButtonTappedProperty = MutableProperty()
  public func alertButtonTapped() { self.alertButtonTappedProperty.value = () }

  fileprivate let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() { self.closeButtonTappedProperty.value = () }

  fileprivate let shouldStartLoadProperty = MutableProperty<(URLRequest, UIWebViewNavigationType)?>(nil)
  fileprivate let shouldStartLoadResponseProperty = MutableProperty(false)
  public func shouldStartLoad(withRequest request: URLRequest,
                              navigationType: UIWebViewNavigationType) -> Bool {
    self.shouldStartLoadProperty.value = (request, navigationType)
    return self.shouldStartLoadResponseProperty.value
  }

  fileprivate let surveyResponseProperty = MutableProperty<SurveyResponse?>(nil)
  public func configureWith(surveyResponse: SurveyResponse) {
    self.surveyResponseProperty.value = surveyResponse
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let dismissViewController: Signal<Void, NoError>
  public let goToProject: Signal<(Param, RefTag?), NoError>
  public let showAlert: Signal<String, NoError>
  public let title: Signal<String, NoError>
  public let webViewLoadRequest: Signal<URLRequest, NoError>

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
