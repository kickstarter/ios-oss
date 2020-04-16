import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class PledgeViewCTAContainerViewModelTests: TestCase {
  let vm: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateSubmitButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateSubmitButtonTapped.observe(self.notifyDelegateSubmitButtonTapped.observer)
    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
  }

  func testApplePayButtonTapped() {
    self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.applePayButtonTapped()

    self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
  }

  func testSubmitButtonTapped() {
    self.notifyDelegateSubmitButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.submitButtonTapped()

    self.notifyDelegateSubmitButtonTapped.assertValueCount(1)
  }

  func testNotifyDelegateOpenHelpType() {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    let allCases = HelpType.allCases.filter { $0 != .contact }

    let allHelpTypeUrls = allCases.map { $0.url(withBaseUrl: baseUrl) }.compact()

    allHelpTypeUrls.forEach { self.vm.inputs.tapped($0) }

    self.notifyDelegateOpenHelpType.assertValues(allCases)
  }
}
