import Prelude
import ReactiveSwift
import Result
import XCTest
import WebKit
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectUpdatesViewModelTests: TestCase {
  fileprivate let vm: ProjectUpdatesViewModelType = ProjectUpdatesViewModel()

  fileprivate let goToSafariBrowser = TestObserver<URL, NoError>()
  fileprivate let goToUpdateId = TestObserver<Int, NoError>()
  fileprivate let goToUpdateCommentId = TestObserver<Int, NoError>()
  fileprivate let webViewLoadRequest = TestObserver<URLRequest, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.goToUpdate.map { project, update in update.id }.observe(self.goToUpdateId.observer)
    self.vm.outputs.goToUpdateComments.map { $0.id }.observe(self.goToUpdateCommentId.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
  }

  func testGoToSafariBrowser() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    let googleURL = URL(string: "http://www.google.com")!

    self.goToSafariBrowser.assertValues([])

    let request = URLRequest(url: googleURL)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData.init(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData.init(mainFrame: true, request: request)
    )

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue,
                   self.vm.inputs.decidePolicy(forNavigationAction: navigationAction).rawValue)

    self.goToSafariBrowser.assertValues([googleURL])
    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual(["project_updates"], self.trackingClient.properties(forKey: "context"))
  }

  func testGoToUpdate() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
      .~ "https://www.kickstarter.com/projects/milk/duds/posts"

    let updateId = 11235

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    let request = URLRequest(url: URL(string: "\(project.urls.web.updates!)/\(updateId)")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData.init(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData.init(mainFrame: true, request: request)
    )

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue,
                   self.vm.inputs.decidePolicy(forNavigationAction: navigationAction).rawValue)

    self.goToUpdateId.assertValues([updateId])
  }

  func testGoToUpdateComments() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
      .~ "https://www.kickstarter.com/projects/smh/lol/posts"

    let updateId = 123456

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    let request = URLRequest(url: URL(string: "\(project.urls.web.updates!)/\(updateId)/comments")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData.init(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData.init(mainFrame: true, request: request)
    )

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue,
                   self.vm.inputs.decidePolicy(forNavigationAction: navigationAction).rawValue)

    self.goToUpdateCommentId.assertValues([updateId])
  }

  func testWebViewLoadRequests() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
      .~ "https://www.kickstarter.com/projects/shrimp/ijc/posts"

    let updatesIndexRequest = AppEnvironment.current.apiService.preparedRequest(
      forURL: URL(string: project.urls.web.updates!)!
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues([updatesIndexRequest])
  }

  func testIFrameRequest() {
    let project = Project.template
      |> (Project.lens.urls.web • Project.UrlsEnvelope.WebEnvelope.lens.updates)
      .~ "https://www.kickstarter.com/projects/shrimp/ijc/posts"

    let updatesIndexRequest = AppEnvironment.current.apiService.preparedRequest(
      forURL: URL(string: project.urls.web.updates!)!
    )

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.webViewLoadRequest.assertValues([updatesIndexRequest])

    let updateRequest = URLRequest(url: URL(string: "https://www.youtube.com/watch")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: updateRequest,
      sourceFrame: WKFrameInfoData.init(mainFrame: true, request: updateRequest),
      targetFrame: WKFrameInfoData.init(mainFrame: false, request: updateRequest)
    )

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue,
                   self.vm.inputs.decidePolicy(forNavigationAction: navigationAction).rawValue)

    self.webViewLoadRequest.assertValues([updatesIndexRequest], "Update loaded in VC, not web view.")
  }
}
