import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result
import WebKit

final class SurveyResponseViewModelTests: TestCase {
  fileprivate let vm: SurveyResponseViewModelType = SurveyResponseViewModel()

  fileprivate let dismissViewController = TestObserver<Void, NoError>()
  fileprivate let goToProjectParam = TestObserver<Param, NoError>()
  fileprivate let showAlert = TestObserver<String, NoError>()
  fileprivate let title = TestObserver<String, NoError>()
  fileprivate let webViewLoadRequestIsPrepared = TestObserver<Bool, NoError>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
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

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: URLRequest(URL: URL(string: project.urls.web.project)!),
        navigationType: .LinkClicked
      )
    )

    self.dismissViewController.assertDidNotEmitValue()
    self.goToProjectParam.assertValues([.slug(project.slug)])
  }

  func testRespondToSurvey() {
    let project = Project.template
    let surveyResponse = .template
      |> SurveyResponse.lens.project .~ project

    self.vm.inputs.configureWith(surveyResponse: surveyResponse)
    self.vm.inputs.viewDidLoad()

    // 1. Load survey.
    self.webViewLoadRequestIsPrepared.assertValues([true])
    self.webViewLoadRequest.assertValueCount(1)

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: surveyRequest(project: project, prepared: true, method: .GET),
        navigationType: .Other
      )
    )

    // 2. Submit survey.
    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: surveyRequest(project: project, prepared: false, method: .POST),
        navigationType: .FormSubmitted
      ),
      "Not prepared"
    )

    self.webViewLoadRequestIsPrepared.assertValues([true, true])
    self.webViewLoadRequest.assertValueCount(2)

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(
        withRequest: surveyRequest(project: project, prepared: true, method: .POST),
        navigationType: .Other
      )
    )

    // 3. Display success alert.
    self.showAlert.assertDidNotEmitValue()

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(
        withRequest: surveyRequest(project: project, prepared: false, method: .GET),
        navigationType: .Other
      ),
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
  let request = NSMutableURLRequest(url: URL(string: url)!)
  request.httpMethod = method.rawValue
  if prepared {
    return AppEnvironment.current.apiService.preparedRequest(forRequest: request)
  } else {
    return request as URLRequest
  }
}
