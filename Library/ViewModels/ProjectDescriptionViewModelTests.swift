// swiftlint:disable force_unwrapping
import Prelude
import ReactiveSwift
import Result
import WebKit
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectDescriptionViewModelTests: TestCase {
  fileprivate let vm: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  fileprivate let goBackToProject = TestObserver<(), NoError>()
  fileprivate let goToMessageDialog = TestObserver<(MessageSubject, Koala.MessageDialogContext), NoError>()
  fileprivate let goToSafariBrowser = TestObserver<URL, NoError>()
  fileprivate let isLoading = TestObserver<Bool, NoError>()
  fileprivate let loadWebViewRequest = TestObserver<URLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goBackToProject.observe(self.goBackToProject.observer)
    self.vm.outputs.goToMessageDialog.observe(self.goToMessageDialog.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
  }

  func testGoBackToProject() {
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1/42"

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.isLoading.assertValues([true])

    self.loadWebViewRequest.assertValueCount(1)

    let request = URLRequest(url: URL(string: project.urls.web.project)!)

    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    self.vm.inputs.webViewDidStartProvisionalNavigation()

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])

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

    let request = URLRequest(url: URL(string: project.urls.web.project + "/messages/new")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    self.vm.inputs.webViewDidStartProvisionalNavigation()

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.scheduler.advance()
    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])
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

    let request = URLRequest(url: URL(string: "https://www.somewhere.com/else")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    self.vm.inputs.webViewDidStartProvisionalNavigation()

    XCTAssertEqual(WKNavigationActionPolicy.cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)
    XCTAssertEqual(["Opened External Link"], self.trackingClient.events)
    XCTAssertEqual(["project_description"], self.trackingClient.properties(forKey: "context"))

    self.scheduler.advance()
    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])
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

    let request = URLRequest(url: URL(string: project.urls.web.project + "/description")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .other,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    self.vm.inputs.webViewDidStartProvisionalNavigation()

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.scheduler.advance()
    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])
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

    let request = URLRequest(url: URL(string: "https://www.youtube.com/watch")!)
    let navigationAction = WKNavigationActionData(
      navigationType: .other,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: false, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    self.vm.inputs.webViewDidStartProvisionalNavigation()

    XCTAssertEqual(WKNavigationActionPolicy.allow.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue,
                   "Loading non-main frame requests permitted, e.g. youtube.")

    self.scheduler.advance()
    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])
    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)
  }
}
