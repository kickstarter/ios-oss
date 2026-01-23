@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import WebKit
import XCTest

final class PledgeManagerWebViewModelTests: TestCase {
  fileprivate let vm: PledgeManagerWebViewModelType = PledgeManagerWebViewModel()

  fileprivate let dismissViewController = TestObserver<Void, Never>()
  fileprivate let goToNativeScreen = TestObserver<PledgeManagerNativeNatigationRequest, Never>()
  fileprivate let presentUpdateVC = TestObserver<(Project, Update), Never>()
  fileprivate let goToLoginSignup = TestObserver<LoginIntent, Never>()
  fileprivate let title = TestObserver<String?, Never>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, Never>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.goToNativeScreen.observe(self.goToNativeScreen.observer)
    self.vm.outputs.presentUpdateVC.observe(self.presentUpdateVC.observer)
    self.vm.outputs.goToLoginSignup.observe(self.goToLoginSignup.observer)
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.webViewLoadRequest
      .map { AppEnvironment.current.apiService.isPrepared(request: $0) }
      .observe(self.webViewLoadRequestIsPrepared.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func DISABLED_SPM_testDismissViewControllerOnCloseButtonTapped() {
    self.vm.inputs.configureWith(url: SurveyResponse.template.urls.web.survey)
    self.vm.inputs.viewDidLoad()
    self.dismissViewController.assertDidNotEmitValue()

    self.vm.inputs.closeButtonTapped()
    self.dismissViewController.assertValueCount(1)
  }

  func DISABLED_SPM_testRespondToSurvey() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.id .~ 123
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(url: surveyResponse.urls.web.survey)
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

  func DISABLED_SPM_testTitle() {
    let project = Project.template
    let basicBackingUrl = "\(project.urls.web.project)/backing/"

    let backingDetailsAction = navigationData(basicBackingUrl + "details")
    _ = self.vm.inputs.decidePolicyFor(navigationAction: backingDetailsAction)
    self.title.assertLastValue(nil)

    let redeemAction = navigationData(basicBackingUrl + "redeem")
    _ = self.vm.inputs.decidePolicyFor(navigationAction: redeemAction)
    self.title.assertLastValue("Pledge Manager")

    let pledgeManagementAction = navigationData(basicBackingUrl + "pledge_management")
    _ = self.vm.inputs.decidePolicyFor(navigationAction: pledgeManagementAction)
    self.title.assertLastValue(nil)

    let surveyAction = navigationData(basicBackingUrl + "survey_responses")
    _ = self.vm.inputs.decidePolicyFor(navigationAction: surveyAction)
    self.title.assertLastValue(nil)
  }

  // MARK: - Test links

  func DISABLED_SPM_testGoToPledge() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(url: surveyResponse.urls.web.survey)
    self.vm.inputs.viewDidLoad()

    self.goToNativeScreen.assertDidNotEmitValue()

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
    self.goToNativeScreen.assertLastValue(.goToPledge(param: .slug(project.slug)))
  }

  func DISABLED_SPM_testGoToProject() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(url: surveyResponse.urls.web.survey)
    self.vm.inputs.viewDidLoad()

    self.goToNativeScreen.assertDidNotEmitValue()

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
    self.goToNativeScreen.assertLastValue(.goToProject(param: .slug(project.slug), refTag: nil))
  }

  func DISABLED_SPM_testGoToUpdate() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    let update = Update.template

    self.vm.inputs.configureWith(url: surveyResponse.urls.web.survey)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(
      fetchProjectResult: .success(project),
      fetchUpdateResponse: update
    )) {
      self.presentUpdateVC.assertDidNotEmitValue()
      self.goToNativeScreen.assertDidNotEmitValue()

      let updateId = 1
      let request = URLRequest(url: URL(string: project.urls.web.project + "/posts/\(updateId)")!)
      let navigationAction = WKNavigationActionData(
        navigationType: .linkActivated,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )

      let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
      XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue, policy.rawValue)

      self.goToNativeScreen.assertLastValue(.goToUpdate(param: .slug(project.slug), updateId: updateId))

      self.vm.inputs.fetchUpdateVCData(param: .slug(project.slug), updateId: updateId)

      self.dismissViewController.assertDidNotEmitValue()
      self.presentUpdateVC.assertValueCount(1)
      let (projectResult, updateResult) = self.presentUpdateVC.lastValue!
      XCTAssertEqual(project, projectResult, "Update project is wrong.")
      XCTAssertEqual(update, updateResult, " Update is wrong.")
    }
  }

  // MARK: - Test login

  func testGoToLoginSignup() {
    withEnvironment(currentUser: nil) {
      let surveyResponse = SurveyResponse.template

      self.vm.inputs.configureWith(url: surveyResponse.urls.web.survey)
      self.vm.inputs.viewDidLoad()

      self.goToLoginSignup.assertValue(.generic)
    }
  }

  func testLoginSuccess() {
    withEnvironment(currentUser: nil) {
      let surveyResponse = SurveyResponse.template

      self.vm.inputs.configureWith(url: surveyResponse.urls.web.survey)
      self.vm.inputs.viewDidLoad()

      // Request should not send when user is logged out.
      self.webViewLoadRequest.assertValueCount(0)

      self.vm.inputs.userSessionStarted()

      // Request should be sent as soon as user has logged in.
      self.webViewLoadRequest.assertValueCount(1)
    }
  }

  // MARK: - Decision policy tests

  func DISABLED_SPM_testDecisionPolicyBypass() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.bypassPledgeManagerDecisionPolicy.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      let navigationData = navigationData("https://www.fake.com/unrecognized-url")
      XCTAssertEqual(
        self.vm.decidePolicyFor(navigationAction: navigationData),
        WKNavigationActionPolicy.allow
      )
    }
  }

  func DISABLED_SPM_testBadRequest() {
    let navigationData = navigationData("https://www.fake.com/bad-url")
    XCTAssertEqual(
      self.vm.decidePolicyFor(navigationAction: navigationData),
      WKNavigationActionPolicy.cancel
    )
  }

  func DISABLED_SPM_testBadStripeRequest() {
    let navigationData = navigationData("https://www.stripecdn.network")
    XCTAssertEqual(
      self.vm.decidePolicyFor(navigationAction: navigationData),
      WKNavigationActionPolicy.cancel
    )
  }

  func DISABLED_SPM_testStripeNetworkRequest() {
    let navigationData = navigationData("https://m.stripe.network/inner.html#url=fake")
    XCTAssertEqual(
      self.vm.decidePolicyFor(navigationAction: navigationData),
      WKNavigationActionPolicy.allow
    )
  }

  func DISABLED_SPM_testStripeElementRequest() {
    let navigationData = navigationData("https://js.stripe.com/v3/controller-fake.html")
    XCTAssertEqual(
      self.vm.decidePolicyFor(navigationAction: navigationData),
      WKNavigationActionPolicy.allow
    )
  }

  func DISABLED_SPM_testStripeCdnRequest() {
    let navigationData = navigationData("https://b.stripecdn.com/assets/v21.19/Captcha.html")
    XCTAssertEqual(
      self.vm.decidePolicyFor(navigationAction: navigationData),
      WKNavigationActionPolicy.allow
    )
  }
}

// MARK: - Helpers

private func navigationData(_ url: String) -> WKNavigationActionData {
  let request = URLRequest(url: URL.init(string: url)!)
  return WKNavigationActionData(
    navigationType: .other,
    request: request,
    sourceFrame: WKFrameInfoData(frameInfo: WKFrameInfo()),
    targetFrame: nil
  )
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
