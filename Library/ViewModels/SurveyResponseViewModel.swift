import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol SurveyResponseViewModelInputs {
  /// Call when the alert OK button is tapped.
  func alertButtonTapped()

  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call to configure with a survey response.
  func configureWith(surveyResponse surveyResponse: SurveyResponse)

  /// Call when the webview decides whether to load a request.
  func shouldStartLoad(withRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool

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
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol SurveyResponseViewModelType: SurveyResponseViewModelInputs, SurveyResponseViewModelOutputs {
  var inputs: SurveyResponseViewModelInputs { get }
  var outputs: SurveyResponseViewModelOutputs { get }
}

public final class SurveyResponseViewModel: SurveyResponseViewModelType {

  // swiftlint:disable function_body_length
  public init() {
    let initialRequest = self.surveyResponseProperty.signal.ignoreNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { surveyResponse -> NSURLRequest? in
        guard let url = NSURL(string: surveyResponse.urls.web.survey) else { return nil }
        return NSURLRequest(URL: url)
      }
      .ignoreNil()

    let postRequest = self.shouldStartLoadProperty.signal.ignoreNil()
      .filter { request, navigationType in
        isUnpreparedSurvey(request: request) && navigationType == .FormSubmitted
      }
      .map { request, _ in request }

    let redirectAfterPostRequest = self.shouldStartLoadProperty.signal.ignoreNil()
      .filter { request, navigationType in
        isUnpreparedSurvey(request: request) && navigationType == .Other
      }
      .map { request, _ in request }

    self.dismissViewController = Signal.merge(
      self.alertButtonTappedProperty.signal,
      self.closeButtonTappedProperty.signal
    )

    self.goToProject = self.shouldStartLoadProperty.signal.ignoreNil()
      .map { request, _ -> (Param, RefTag?)? in
        if case let (.project(param, .root, refTag))? = Navigation.match(request) {
          return (param, refTag)
        }
        return nil
      }
      .ignoreNil()

    self.shouldStartLoadResponseProperty <~ self.shouldStartLoadProperty.signal.ignoreNil()
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

  private let alertButtonTappedProperty = MutableProperty()
  public func alertButtonTapped() { self.alertButtonTappedProperty.value = () }

  private let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() { self.closeButtonTappedProperty.value = () }

  private let shouldStartLoadProperty = MutableProperty<(NSURLRequest, UIWebViewNavigationType)?>(nil)
  private let shouldStartLoadResponseProperty = MutableProperty(false)
  public func shouldStartLoad(withRequest request: NSURLRequest,
                                          navigationType: UIWebViewNavigationType) -> Bool {
    self.shouldStartLoadProperty.value = (request, navigationType)
    return self.shouldStartLoadResponseProperty.value
  }

  private let surveyResponseProperty = MutableProperty<SurveyResponse?>(nil)
  public func configureWith(surveyResponse surveyResponse: SurveyResponse) {
    self.surveyResponseProperty.value = surveyResponse
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let dismissViewController: Signal<Void, NoError>
  public let goToProject: Signal<(Param, RefTag?), NoError>
  public let showAlert: Signal<String, NoError>
  public let title: Signal<String, NoError>
  public let webViewLoadRequest: Signal<NSURLRequest, NoError>

  public var inputs: SurveyResponseViewModelInputs { return self }
  public var outputs: SurveyResponseViewModelOutputs { return self }
}

private func isUnpreparedSurvey(request request: NSURLRequest) -> Bool {
  guard !AppEnvironment.current.apiService.isPrepared(request: request) else { return false }
  return isSurvey(request: request)
}

private func isSurvey(request request: NSURLRequest) -> Bool {
  guard case (.project(_, .survey(_), _))? = Navigation.match(request) else { return false }
  return true
}
