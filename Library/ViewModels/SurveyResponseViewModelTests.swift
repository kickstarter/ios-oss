@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import WebKit
import XCTest

final class SurveyResponseViewModelTests: TestCase {
  fileprivate let vm: SurveyResponseViewModelType = SurveyResponseViewModel()

  fileprivate let dismissViewController = TestObserver<Void, Never>()
  fileprivate let extractFormDataWithJavaScript = TestObserver<String, Never>()
  fileprivate let goToProjectParam = TestObserver<Param, Never>()
  fileprivate let showAlert = TestObserver<String, Never>()
  fileprivate let title = TestObserver<String, Never>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, Never>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.extractFormDataWithJavaScript.observe(self.extractFormDataWithJavaScript.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProjectParam.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.webViewLoadRequest
      .map { AppEnvironment.current.apiService.isPrepared(request: $0) }
      .observe(self.webViewLoadRequestIsPrepared.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testDismissViewControllerOnCloseButtonTapped() {
    self.vm.inputs.configureWith(surveyResponse: .template)
    self.vm.inputs.viewDidLoad()
    self.dismissViewController.assertDidNotEmitValue()

    self.vm.inputs.closeButtonTapped()
    self.dismissViewController.assertValueCount(1)
  }

  func testGoToProject() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(surveyResponse: surveyResponse)
    self.vm.inputs.viewDidLoad()

    self.goToProjectParam.assertDidNotEmitValue()

    let request = URLRequest(url: URL(string: project.urls.web.project)!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue, policy.rawValue)

    self.dismissViewController.assertDidNotEmitValue()
    self.goToProjectParam.assertValues([.slug(project.slug)])
  }

  func testRespondToSurvey() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.id .~ 123
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(surveyResponse: surveyResponse)
    self.vm.inputs.viewDidLoad()

    // 1. Load survey.
    self.webViewLoadRequestIsPrepared.assertValues([true])
    self.webViewLoadRequest.assertValueCount(1)

    let surveyPreparedGetRequest = surveyRequest(project: project, prepared: true, method: .GET)

    let surveyPreparedGetRequestNavigationAction = WKNavigationActionData(
      navigationType: .other,
      request: surveyPreparedGetRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: surveyPreparedGetRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: surveyPreparedGetRequest)
    )

    let surveyPreparedGetRequestPolicy = self.vm.inputs.decidePolicyFor(
      navigationAction: surveyPreparedGetRequestNavigationAction
    )

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue, surveyPreparedGetRequestPolicy.rawValue)

    // 2. Submit unprepared survey.
    let surveyUnpreparedPostRequest = surveyRequest(project: project, prepared: false, method: .POST)

    let surveyUnpreparedPostRequestNavigationAction = WKNavigationActionData(
      navigationType: .formSubmitted,
      request: surveyUnpreparedPostRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: surveyUnpreparedPostRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: surveyUnpreparedPostRequest)
    )

    let surveyUnpreparedPostRequestPolicy = self.vm.inputs.decidePolicyFor(
      navigationAction: surveyUnpreparedPostRequestNavigationAction
    )

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue, surveyUnpreparedPostRequestPolicy.rawValue,
      "Not prepared"
    )

    self.extractFormDataWithJavaScript.assertValues(["$('#edit_survey_response_123').serialize()"])
    self.vm.inputs.didEvaluateJavaScriptWithResult("data=data")
    XCTAssertEqual(self.webViewLoadRequest.values.last?.httpBody, "data=data".data(using: .utf8))

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequest.assertValueCount(2)

    // 3. Submit prepared survey.
    let surveyPreparedPostRequest = surveyRequest(project: project, prepared: true, method: .POST)

    let surveyPreparedPostRequestNavigationAction = WKNavigationActionData(
      navigationType: .other,
      request: surveyPreparedPostRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: surveyPreparedPostRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: surveyPreparedPostRequest)
    )

    let surveyPreparedPostRequestPolicy = self.vm.inputs.decidePolicyFor(
      navigationAction: surveyPreparedPostRequestNavigationAction
    )

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue, surveyPreparedPostRequestPolicy.rawValue)

    // 3. Display success alert.
    self.showAlert.assertDidNotEmitValue()

    let surveyRedirectGetRequest = surveyRequest(project: project, prepared: false, method: .GET)

    let surveyRedirectGetRequestNavigationAction = WKNavigationActionData(
      navigationType: .other,
      request: surveyRedirectGetRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: surveyRedirectGetRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: surveyRedirectGetRequest)
    )

    let surveyRedirectGetRequestPolicy = self.vm.inputs.decidePolicyFor(
      navigationAction: surveyRedirectGetRequestNavigationAction
    )

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue, surveyRedirectGetRequestPolicy.rawValue,
      "Intercept redirect to survey"
    )

    self.showAlert.assertValues([Strings.Got_it_your_survey_response_has_been_submitted()])

    // 4. Tap OK on alert, dismiss view controller.
    self.dismissViewController.assertDidNotEmitValue()

    self.vm.inputs.alertButtonTapped()
    self.dismissViewController.assertValueCount(1)
  }

  func testTitle() {
    self.vm.inputs.configureWith(surveyResponse: .template)
    self.title.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.title.assertValues([Strings.Survey()])
  }
}

private func surveyRequest(project: Project, prepared: Bool, method: KsApi.Method) -> URLRequest {
  let url = "\(project.urls.web.project)/surveys/1"
  var request = URLRequest(url: URL(string: url)!)
  request.httpMethod = method.rawValue
  if prepared {
    return AppEnvironment.current.apiService.preparedRequest(forRequest: request)
  } else {
    return request
  }
}
