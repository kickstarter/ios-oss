@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import WebKit
import XCTest

final class UpdateViewModelTests: TestCase {
  fileprivate let vm: UpdateViewModelType = UpdateViewModel()

  fileprivate let project = .template |> Project.lens.id .~ 1
  fileprivate let update = .template
    |> Update.lens.projectId .~ 1

  fileprivate let goToComments = TestObserver<Update, Never>()
  fileprivate let goToProject = TestObserver<Project, Never>()
  fileprivate let goToSafariBrowser = TestObserver<URL, Never>()
  fileprivate let title = TestObserver<String, Never>()
  fileprivate let webViewLoadRequest = TestObserver<String?, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.webViewLoadRequest.map { $0.url?.absoluteString }
      .observe(self.webViewLoadRequest.observer)
  }

  func testUpdateUrlLoads() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    let query = "client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)&currency=USD"
    self.webViewLoadRequest.assertValues(
      ["\(self.update.urls.web.update)?\(query)"]
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
      .flatMap { $0.deletingLastPathComponent() }
      .map { $0.appendingPathComponent(String(prevUpdate.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchUpdateResponse: prevUpdate)) {
      let request = URLRequest(url: prevUpdateUrl)
      let navigationAction = WKNavigationActionData(
        navigationType: .linkActivated,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )

      let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

      XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue, policy.rawValue)

      self.goToSafariBrowser.assertDidNotEmitValue("New update request should not load in Safari browser.")

      let query = "client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)&currency=USD"
      self.webViewLoadRequest.assertValues(
        [
          "\(self.update.urls.web.update)?\(query)",
          "\(prevUpdateUrl.absoluteString)?\(query)"
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
      .flatMap { $0.deletingLastPathComponent() }
      .map { $0.appendingPathComponent(String(anotherProject.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchProjectResponse: anotherProject)) {
      let request = URLRequest(url: anotherProjectUrl)
      let navigationAction = WKNavigationActionData(
        navigationType: .linkActivated,
        request: request,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request)
      )

      let policy = self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

      XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue, policy.rawValue)

      self.goToProject.assertValues([anotherProject])
      self.goToComments.assertValueCount(0)
    }

    let query = "client_id=\(self.apiService.serverConfig.apiClientAuth.clientId)&currency=USD"
    self.webViewLoadRequest.assertValues(
      ["\(self.update.urls.web.update)?\(query)"]
    )
  }

  func testGoToComments() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    let commentsRequest = URL(string: self.update.urls.web.update)
      .map { $0.appendingPathComponent("comments") }
      .flatMap { URLRequest.init(url: $0) }!

    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: commentsRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: commentsRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: commentsRequest)
    )

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue,
      self.vm.inputs.decidePolicyFor(navigationAction: navigationAction).rawValue
    )
    self.goToComments.assertValues([self.update])
    self.goToProject.assertDidNotEmitValue()
    self.goToSafariBrowser.assertDidNotEmitValue()
  }

  func testGoToSafariBrowser() {
    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    let updateRequest = URLRequest(url: URL(string: self.update.urls.web.update)!)
    var navigationAction = WKNavigationActionData(
      navigationType: .other,
      request: updateRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: updateRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: updateRequest)
    )

    XCTAssertEqual(
      WKNavigationActionPolicy.allow.rawValue,
      self.vm.inputs.decidePolicyFor(navigationAction: navigationAction).rawValue
    )
    self.webViewLoadRequest.assertValueCount(1)
    self.goToSafariBrowser.assertDidNotEmitValue()

    let outsideUrl = URL(string: "http://www.wikipedia.com")!
    let outsideRequest = URLRequest(url: outsideUrl)

    navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: outsideRequest,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: outsideRequest),
      targetFrame: WKFrameInfoData(mainFrame: true, request: outsideRequest)
    )

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue,
      self.vm.inputs.decidePolicyFor(navigationAction: navigationAction).rawValue
    )
    self.goToComments.assertValueCount(0)
    self.goToProject.assertValueCount(0)
    self.webViewLoadRequest.assertValueCount(1)
    self.goToSafariBrowser.assertValues([outsideUrl])

    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual("project_update", self.trackingClient.properties.last?["context"] as? String)
  }

  func testGoToSafariBrowser_PrelaunchProject() {
    let prelaunchProject = Project.template
      |> Project.lens.id .~ 10
      |> Project.lens.prelaunchActivated .~ true
    let prelaunchProjectURL = URL(string: prelaunchProject.urls.web.project)
      .flatMap { $0.deletingLastPathComponent() }
      .map { $0.appendingPathComponent(String(prelaunchProject.id)) }!

    self.vm.inputs.configureWith(project: self.project, update: self.update)
    self.vm.inputs.viewDidLoad()

    withEnvironment(apiService: MockService(fetchProjectResponse: prelaunchProject)) {
      guard let google = URL(string: "https://www.google.com") else {
        XCTFail("Should have a URL")
        return
      }

      let request1 = URLRequest(url: google)

      let navigationAction1 = WKNavigationActionData(
        navigationType: .other,
        request: request1,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request1),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request1)
      )

      XCTAssertEqual(
        WKNavigationActionPolicy.allow.rawValue,
        self.vm.inputs.decidePolicyFor(navigationAction: navigationAction1).rawValue
      )

      self.scheduler.run()

      self.goToProject.assertDidNotEmitValue()
      self.goToComments.assertDidNotEmitValue()
      self.webViewLoadRequest.assertValueCount(1, "Initial update load request")
      self.goToSafariBrowser.assertValues([])

      XCTAssertEqual([], self.trackingClient.events)
      XCTAssertEqual(nil, self.trackingClient.properties.last?["context"] as? String)

      let request2 = URLRequest(url: prelaunchProjectURL)

      let navigationAction2 = WKNavigationActionData(
        navigationType: .linkActivated,
        request: request2,
        sourceFrame: WKFrameInfoData(mainFrame: true, request: request2),
        targetFrame: WKFrameInfoData(mainFrame: true, request: request2)
      )

      XCTAssertEqual(
        WKNavigationActionPolicy.cancel.rawValue,
        self.vm.inputs.decidePolicyFor(navigationAction: navigationAction2).rawValue
      )

      self.scheduler.run()

      self.goToProject.assertDidNotEmitValue()
      self.goToComments.assertDidNotEmitValue()
      self.webViewLoadRequest.assertValueCount(1, "Initial update load request")
      self.goToSafariBrowser.assertValues([prelaunchProjectURL])

      XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
      XCTAssertEqual("project_update", self.trackingClient.properties.last?["context"] as? String)
    }
  }
}
