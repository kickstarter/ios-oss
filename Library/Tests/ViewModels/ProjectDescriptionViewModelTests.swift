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

  private let footerHidden = TestObserver<Bool, NoError>()
  private let layoutFooterAndHeaderWithDescriptionExpanded = TestObserver<Bool, NoError>()
  private let layoutFooterAndHeaderWithContentOffset = TestObserver<CGPoint?, NoError>()
  private let loadWebViewRequest = TestObserver<NSURLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.footerHidden.observe(self.footerHidden.observer)
    self.vm.outputs.layoutFooterAndHeader.map(first)
      .observe(self.layoutFooterAndHeaderWithDescriptionExpanded.observer)
    self.vm.outputs.layoutFooterAndHeader.map(second)
      .observe(self.layoutFooterAndHeaderWithContentOffset.observer)
    self.vm.outputs.loadWebViewRequest.observe(self.loadWebViewRequest.observer)
  }

  func testFooterHidden() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: .template)
    self.vm.inputs.transferredHeaderAndFooter(atContentOffset: .zero)
    self.vm.inputs.viewDidAppear()

    self.footerHidden.assertValues([true], "Footer is initially hidden")

    self.vm.inputs.observedWebViewContentSizeChange(.zero)

    self.footerHidden.assertValues([true, false], "Footer shows after web view gets its size.")
  }

  func testLayoutFooterAndHeader() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: .template)
    self.vm.inputs.transferredHeaderAndFooter(atContentOffset: .zero)
    self.vm.inputs.viewDidAppear()

    self.layoutFooterAndHeaderWithDescriptionExpanded.assertValues([false])
    self.layoutFooterAndHeaderWithContentOffset.assertValues([.zero])

    self.vm.inputs.observedWebViewContentSizeChange(.zero)

    self.layoutFooterAndHeaderWithDescriptionExpanded.assertValues([false, false])
    self.layoutFooterAndHeaderWithContentOffset.assertValues([.zero, nil])

    self.vm.inputs.webViewDidFinishNavigation()

    self.layoutFooterAndHeaderWithDescriptionExpanded.assertValues([false, false, false])
    self.layoutFooterAndHeaderWithContentOffset.assertValues([.zero, nil, nil])

    self.vm.inputs.expandDescription()

    self.layoutFooterAndHeaderWithDescriptionExpanded.assertValues([false, false, false, true])
    self.layoutFooterAndHeaderWithContentOffset.assertValues([.zero, nil, nil, nil])

    self.vm.inputs.transferredHeaderAndFooter(atContentOffset: CGPoint(x: 0, y: 100))

    self.layoutFooterAndHeaderWithDescriptionExpanded.assertValues([false, false, false, true, true])
    self.layoutFooterAndHeaderWithContentOffset.assertValues([.zero, nil, nil, nil, CGPoint(x: 0, y: 100)])
  }

  func testLoadWebViewRequest() {
    let project = Project.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.transferredHeaderAndFooter(atContentOffset: .zero)
    self.vm.inputs.viewDidAppear()

    self.loadWebViewRequest.assertValueCount(1)

    var decision = self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .Other,
        request: NSURLRequest(URL: NSURL(string: project.urls.web.project + "/description")!)
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.Allow.rawValue, decision.rawValue)

    decision = self.vm.inputs.decidePolicyFor(
      navigationAction: MockNavigationAction(
        navigationType: .Other,
        request: NSURLRequest(URL: NSURL(string: "https://www.somehwere-else.com")!)
      )
    )

    XCTAssertEqual(WKNavigationActionPolicy.Cancel.rawValue, decision.rawValue)
  }
}
