@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import WebKit
import XCTest

final class SurveyResponseViewModelTests: TestCase {
  fileprivate let vm: SurveyResponseViewModelType = SurveyResponseViewModel()

  fileprivate let dismissViewController = TestObserver<Void, Never>()
  fileprivate let goToPledge = TestObserver<Param, Never>()
  fileprivate let goToProjectParam = TestObserver<Param, Never>()
  fileprivate let goToUpdate = TestObserver<(Project, Update), Never>()
  fileprivate let title = TestObserver<String, Never>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, Never>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.goToPledge.observe(self.goToPledge.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProjectParam.observer)
    self.vm.outputs.goToUpdate.observe(self.goToUpdate.observer)
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

    // 2. Submit unprepared survey with non-nil body.
    var surveyUnpreparedPostRequest = surveyRequest(project: project, prepared: false, method: .POST)
    surveyUnpreparedPostRequest.httpBody = "data=data".data(using: .utf8)

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

    XCTAssertEqual(self.webViewLoadRequest.values.last?.httpBody, "data=data".data(using: .utf8))

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequest.assertValueCount(2)

    // 3. Redirect to completed responses.
    let surveyRedirectGetRequest = surveyRequest(project: project, prepared: true, method: .GET)

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
      WKNavigationActionPolicy.allow.rawValue, surveyRedirectGetRequestPolicy.rawValue,
      "Allow redirect to completed survey responses"
    )

    // 4. Tap close button, dismiss view controller.
    self.dismissViewController.assertDidNotEmitValue()

    self.vm.inputs.closeButtonTapped()
    self.dismissViewController.assertValueCount(1)
  }

  func testTitle() {
    self.vm.inputs.configureWith(surveyResponse: .template)
    self.title.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.title.assertValues([Strings.Survey()])
  }

  // MARK: - Test links

  func testGoToPledge() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(surveyResponse: surveyResponse)
    self.vm.inputs.viewDidLoad()

    self.goToPledge.assertDidNotEmitValue()

    let request = URLRequest(url: URL(string: project.urls.web.project + "/pledge/edit")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue, policy.rawValue)

    self.dismissViewController.assertDidNotEmitValue()
    self.goToPledge.assertValues([.slug(project.slug)])
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

  func testGoToUpdate() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    let update = Update.template

    self.vm.inputs.configureWith(surveyResponse: surveyResponse)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(
      fetchProjectResult: .success(project),
      fetchUpdateResponse: update
    )) {
      self.goToUpdate.assertDidNotEmitValue()

      let request = URLRequest(url: URL(string: project.urls.web.project + "/posts/1")!)
      let navigationAction = WKNavigationActionData(
        navigationType: .linkActivated,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )

      let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
      XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue, policy.rawValue)

      self.dismissViewController.assertDidNotEmitValue()
      self.goToUpdate.assertValueCount(1)
      let (projectResult, updateResult) = self.goToUpdate.lastValue!
      XCTAssertEqual(project, projectResult, "Update project is wrong.")
      XCTAssertEqual(update, updateResult, " Update is wrong.")
    }
  }
}

// MARK: - Helpers

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
