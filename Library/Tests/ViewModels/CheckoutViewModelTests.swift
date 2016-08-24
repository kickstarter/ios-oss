import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import Prelude

final class CheckoutViewModelTests: TestCase {
  private let vm: CheckoutViewModelType = CheckoutViewModel()

  private let closeLoginTout = TestObserver<Void, NoError>()
  private let openLoginTout = TestObserver<Void, NoError>()
  private let goToSafariBrowser = TestObserver<NSURL, NoError>()
  private let goToThanks = TestObserver<Project, NoError>()
  private let goToWebModal = TestObserver<NSURLRequest, NoError>()
  private let popViewController = TestObserver<Void, NoError>()
  private let webViewLoadRequest = TestObserver<NSURLRequest, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.closeLoginTout.observe(self.closeLoginTout.observer)
    self.vm.outputs.openLoginTout.observe(self.openLoginTout.observer)
    self.vm.outputs.goToSafariBrowser.observe(self.goToSafariBrowser.observer)
    self.vm.outputs.goToThanks.observe(self.goToThanks.observer)
    self.vm.outputs.goToWebModal.observe(self.goToWebModal.observer)
    self.vm.outputs.popViewController.observe(self.popViewController.observer)
    self.vm.outputs.webViewLoadRequest.observe(self.webViewLoadRequest.observer)
  }

  func testModalRequests() {
    self.vm.inputs.configureWith(project: .template, reward: nil, intent: .new)
    self.vm.inputs.viewDidLoad()

    XCTAssertTrue(
      self.vm.inputs.shouldStartLoad(withRequest: self.newPledgeRequest.prepared(),
        navigationType: .Other)
    )
    self.goToWebModal.assertValueCount(0)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: self.creatorRequest,
        navigationType: .LinkClicked)
    )
    self.goToSafariBrowser.assertValueCount(0)
    self.goToWebModal.assertValueCount(1)

    XCTAssertFalse(
      self.vm.inputs.shouldStartLoad(withRequest: self.privacyPolicyRequest,
        navigationType: .LinkClicked)
    )
    self.goToSafariBrowser.assertValueCount(1)
    self.goToWebModal.assertValueCount(1)
  }

  private let creatorRequest =
    NSURLRequest(URL:
      NSURL(string: "https://www.kickstarter.com/projects/tfw/ijc/pledge/big_print?modal=true#creator")!
  )

  private let newPledgeRequest =
    NSURLRequest(URL:
      NSURL(string: "https://www.kickstarter.com/projects/tfw/ijc/pledge/new")!
  )

  let privacyPolicyRequest =
    NSURLRequest(URL:
      NSURL(string: "https://www.kickstarter.com/privacy?modal=true&ref=checkout_payment_sources_page")!
  )

  private let projectRequest =
    NSURLRequest(URL:
      NSURL(string: "https://www.kickstarter.com/projects/tfw/ijc")!
  )
}

internal extension NSURLRequest {
  internal func prepared() -> NSURLRequest {
    return AppEnvironment.current.apiService.preparedRequest(forRequest: self)
  }
}
