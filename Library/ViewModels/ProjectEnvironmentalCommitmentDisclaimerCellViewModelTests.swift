@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectEnvironmentalCommitmentDisclaimerCellViewModelTests: TestCase {
  fileprivate let vm: ProjectEnvironmentalCommitmentDisclaimerCellViewModelType =
    ProjectEnvironmentalCommitmentDisclaimerCellViewModel()

  fileprivate let notifyDelegateLinkTappedWithURL = TestObserver<URL, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateLinkTappedWithURL.observe(self.notifyDelegateLinkTappedWithURL.observer)
  }

  func testOutput_NotifyDelegateLinkTappedWithURL() {
    let url = URL(string: "https://www.foobar.com")!

    self.vm.inputs.configure()

    self.notifyDelegateLinkTappedWithURL.assertDidNotEmitValue()

    self.vm.inputs.linkTapped(url: url)

    self.notifyDelegateLinkTappedWithURL.assertValues([url])
  }
}
