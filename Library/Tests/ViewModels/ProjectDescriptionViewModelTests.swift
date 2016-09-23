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

    self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: NSURLRequest(URL: NSURL(string: project.urls.web.project)!)
      )
    )

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

    self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: NSURLRequest(URL: NSURL(string: project.urls.web.project + "/messages/new")!)
      )
    )

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

    self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .LinkActivated,
        request: NSURLRequest(URL: NSURL(string: "https://www.somewhere.com/else")!)
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

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

    self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .Other,
        request: NSURLRequest(URL: NSURL(string: project.urls.web.project + "/description")!)
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.Allow.rawValue,
                   self.vm.outputs.decidedPolicyForNavigationAction.rawValue)

    self.loadWebViewRequest.assertValueCount(1)
    self.goBackToProject.assertValueCount(0)
    self.goToMessageDialog.assertValueCount(0)
    self.goToSafariBrowser.assertValueCount(0)
  }
}
