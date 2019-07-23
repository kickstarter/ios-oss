@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeSummaryViewModelTests: TestCase {
  private let vm: PledgeSummaryViewModelType = PledgeSummaryViewModel()

  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
  }

  func testNotifyDelegateOpenHelpType() {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    let allCases = HelpType.allCases.filter { $0 != .contact }

    let allHelpTypeUrls = allCases.map { $0.url(withBaseUrl: baseUrl) }.compact()

    allHelpTypeUrls.forEach { self.vm.inputs.tapped($0) }

    self.notifyDelegateOpenHelpType.assertValues(allCases)
  }
}
