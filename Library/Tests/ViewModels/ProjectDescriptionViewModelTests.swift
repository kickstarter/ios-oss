import Prelude
import ReactiveCocoa
import Result
import WebKit
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectDescriptionViewModelTests: TestCase {
  private let vm: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  private let goBackToProject = TestObserver<(), NoError>()
  private let goToMessageDialog = TestObserver<(MessageSubject, Koala.MessageDialogContext), NoError>()
  private let goToSafariBrowser = TestObserver<NSURL, NoError>()
  private let loadWebViewRequest = TestObserver<NSURLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goBackToProject.observe(self.goBackToProject.observer)
    self.vm.outputs.goToMessageDialog.observe(self.goToMessageDialog.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
  }

  func testGoBackToProject() {
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1/42"

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValueCount(1)

    let request = NSURLRequest(URL: NSURL(string: project.urls.web.project)!)

    let navigationAction = WKNavigationActionData(
      navigationType: .LinkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(1)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)
  }

  func testGoToMessageDialog() {
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1/42"

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValueCount(1)

    let request = NSURLRequest(URL: NSURL(string: project.urls.web.project + "/messages/new")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .LinkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(1)
    self.goToSafariBrowser.assertValueCount(0)
  }

  func testGoToSafari() {
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1/42"

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValueCount(1)

    let request = NSURLRequest(URL: NSURL(string: "https://www.somewhere.com/else")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .LinkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)
    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual(["project_description"], self.trackingClient.properties(forKey: "context"))

    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(1)
  }

  func testDescriptionRequest() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValueCount(1)

    let request = NSURLRequest(URL: NSURL(string: project.urls.web.project + "/description")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .Other,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.Allow.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)
  }

  func testIFrameRequest() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.loadWebViewRequest.assertValueCount(1)

    let request = NSURLRequest(URL: NSURL(string: "https://www.youtube.com/watch")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .Other,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: false, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)

    XCTAssertEqual(WKNavigationActionPolicy.Allow.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue,
                   "Loading non-main frame requests permitted, e.g. youtube.")

    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)
  }
}
