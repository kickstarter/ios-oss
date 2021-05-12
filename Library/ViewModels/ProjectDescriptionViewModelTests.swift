@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import WebKit
import XCTest

final class ProjectDescriptionViewModelTests: TestCase {
  private let vm: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  private let goBackToProject = TestObserver<(), Never>()
  private let goToMessageDialog = TestObserver<(MessageSubject, KSRAnalytics.MessageDialogContext), Never>()
  private let goToSafariBrowser = TestObserver<URL, Never>()
  private let isLoading = TestObserver<Bool, Never>()
  private let loadWebViewRequest = TestObserver<URLRequest, Never>()
  private let pledgeCTAContainerViewIsHidden = TestObserver<Bool, Never>()
  private let showErrorAlert = TestObserver<NSError, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goBackToProject.observe(self.goBackToProject.observer)
    self.vm.outputs.goToMessageDialog.observe(self.goToMessageDialog.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
    self.vm.outputs.showErrorAlert.map { $0 as NSError }.observe(self.showErrorAlert.observer)
  }

  func testGoBackToProject() {
    let project = .template
      |> Project.lens.id .~ 42
      |> Project.lens.urls.web.project .~ "https://www.kickstarter.com/projects/1/42"

    self.vm.inputs.configureWith(value: (project, nil))
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

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue,
      self.vm.outputs.decidedPolicyForNavigationAction.rawValue
    )

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

    self.vm.inputs.configureWith(value: (project, nil))
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

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue,
      self.vm.outputs.decidedPolicyForNavigationAction.rawValue
    )

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

    self.vm.inputs.configureWith(value: (project, nil))
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

    XCTAssertEqual(
      WKNavigationActionPolicy.cancel.rawValue,
      self.vm.outputs.decidedPolicyForNavigationAction.rawValue
    )

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

    self.vm.inputs.configureWith(value: (project, .discovery))
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

    XCTAssertEqual(
      WKNavigationActionPolicy.allow.rawValue,
      self.vm.outputs.decidedPolicyForNavigationAction.rawValue
    )

    self.scheduler.advance()
    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])
    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

    XCTAssertEqual(["campaign"], self.segmentTrackingClient.properties(forKey: "context_section"))

    XCTAssertEqual(["discovery"], self.segmentTrackingClient.properties(forKey: "session_ref_tag"))
  }

  func testIFrameRequest() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, nil))
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

    XCTAssertEqual(
      WKNavigationActionPolicy.allow.rawValue,
      self.vm.outputs.decidedPolicyForNavigationAction.rawValue,
      "Loading non-main frame requests permitted, e.g. youtube."
    )

    self.scheduler.advance()
    self.vm.inputs.webViewDidFinishNavigation()

    self.isLoading.assertValues([true, false])
    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)
  }

  func testError() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()

    let request = URLRequest(url: URL(string: project.urls.web.project)!)

    let navigationAction = WKNavigationActionData(
      navigationType: .linkActivated,
      request: request,
      sourceFrame: WKFrameInfoData(mainFrame: true, request: request),
      targetFrame: WKFrameInfoData(mainFrame: true, request: request)
    )

    self.vm.inputs.decidePolicyFor(navigationAction: navigationAction)
    self.vm.inputs.webViewDidStartProvisionalNavigation()

    let error = NSError(
      domain: "notonlinesorry", code: -666, userInfo: [NSLocalizedDescriptionKey: "Not online sorry"]
    )
    self.vm.inputs.webViewDidFailProvisionalNavigation(withError: error)

    self.showErrorAlert.assertValues([error])
  }
}
