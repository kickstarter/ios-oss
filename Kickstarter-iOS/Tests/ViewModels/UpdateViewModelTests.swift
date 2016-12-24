@testable import Library
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import KsApi
import Prelude
import ReactiveSwift
import Result
import XCTest

final class UpdateViewModelTests: TestCase {
  private let vm: UpdateViewModelType = UpdateViewModel()

  private let project = .template |> Project.lens.id .~ 1
  private let update = .template
    |> Update.lens.projectId .~ 1

  private let goToComments = TestObserver<Update, NoError>()
  private let goToProject = TestObserver<Project, NoError>()
  private let goToSafariBrowser = TestObserver<URL, NoError>()
  private let title = TestObserver<String, NoError>()
  private let webViewLoadRequest = TestObserver<String?, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.webViewLoadRequest.map { $0.URL?.absoluteString }
      .observe(self.webViewLoadRequest.observer)
  }

  func testUpdateUrlLoads() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues(
      ["\(self.update.urls.web.update)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"]
    )
  }

  func testTitle() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    self.title.assertValues(
      [Strings.activity_project_update_update_count(update_count: String(self.update.sequence))]
    )
  }

  func testGoToAnotherUpdate() {
    let prevUpdate = .template
      |> Update.lens.id .~ 42
      |> Update.lens.sequence .~ 42

    let prevUpdateUrl = URL(string: prevUpdate.urls.web.update)
      .flatMap { $0.URLByDeletingLastPathComponent }
      .map { $0.URLByAppendingPathComponent(String(prevUpdate.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchUpdateResponse: prevUpdate)) {

      let request = URLRequest(URL: optionalize(prevUpdateUrl)!)
      let navigationAction = WKNavigationActionData(
        navigationType: .LinkActivated,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )

      let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

      XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue, policy.rawValue)

      self.webViewLoadRequest.assertValues(
        [
          "\(self.update.urls.web.update)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)",
          "\((optionalize(prevUpdateUrl)?.absoluteString)!)" +
            "?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"
        ]
      )

      self.title.assertValues(
        [
          Strings.activity_project_update_update_count(update_count: String(self.update.sequence)),
          Strings.activity_project_update_update_count(update_count: String(prevUpdate.sequence))
        ]
      )
    }
  }

  func testGoToProject() {
    let anotherProject = .template |> Project.lens.id .~ 42
    let anotherProjectUrl = URL(string: anotherProject.urls.web.project)
      .flatMap { $0.URLByDeletingLastPathComponent }
      .map { $0.URLByAppendingPathComponent(String(anotherProject.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchProjectResponse: anotherProject)) {

      let request = URLRequest(URL: optionalize(anotherProjectUrl)!)
      let navigationAction = WKNavigationActionData(
        navigationType: .LinkActivated,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )

      let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

      XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue, policy.rawValue)

      self.goToProject.assertValues([anotherProject])
      self.goToComments.assertValueCount(0)
    }

    self.webViewLoadRequest.assertValues(
      ["\(self.update.urls.web.update)?client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)"]
    )
  }

  func testGoToComments() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    let commentsRequest = URL(string: self.update.urls.web.update)
      .map { $0.URLByAppendingPathComponent("comments") }
      .flatMap(URLRequest.init(URL:))!

    let navigationAction = WKNavigationActionData(
      navigationType: .LinkActivated,
      request: commentsRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: commentsRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: commentsRequest)
    )

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue,
                   self.vm.inputs.decidePolicyFor(navigationAction: navigationAction).rawValue)
    self.goToComments.assertValues([self.update])
  }

  func testGoToSafariBrowser() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    let updateRequest = URLRequest(URL: URL(string: self.update.urls.web.update)!)
    var navigationAction = WKNavigationActionData(
      navigationType: .Other,
      request: updateRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: updateRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: updateRequest)
    )

    XCTAssertEqual(WKNavigationActionPolicy.Allow.rawValue,
                   self.vm.inputs.decidePolicyFor(navigationAction: navigationAction).rawValue)
    self.webViewLoadRequest.assertValueCount(1)

    let outsideUrl = URL(string: "http://www.wikipedia.com")!
    let outsideRequest = URLRequest(URL: outsideUrl)

    navigationAction = WKNavigationActionData(
      navigationType: .LinkActivated,
      request: outsideRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: outsideRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: outsideRequest)
    )

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue,
                   self.vm.inputs.decidePolicyFor(navigationAction: navigationAction).rawValue)
    self.goToComments.assertValueCount(0)
    self.goToProject.assertValueCount(0)
    self.webViewLoadRequest.assertValueCount(1)
    self.goToSafariBrowser.assertValues([outsideUrl])

    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual(["project_update"], self.trackingClient.properties(forKey: "context"))
  }
}
