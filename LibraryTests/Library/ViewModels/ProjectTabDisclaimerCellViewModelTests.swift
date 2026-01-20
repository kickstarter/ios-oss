@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveSwift
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectTabDisclaimerCellViewModelTests: TestCase {
  fileprivate let vm: ProjectTabDisclaimerCellViewModelType =
    ProjectTabDisclaimerCellViewModel()

  fileprivate let notifyDelegateLinkTappedWithURL = TestObserver<URL, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateLinkTappedWithURL.observe(self.notifyDelegateLinkTappedWithURL.observer)
  }

  func testOutput_NotifyDelegateLinkTappedWithURL() {
    let url = URL(string: "https://www.foobar.com")!

    self.vm.inputs.configure(with: .aiDisclosure)

    self.notifyDelegateLinkTappedWithURL.assertDidNotEmitValue()

    self.vm.inputs.linkTapped(url: url)

    self.notifyDelegateLinkTappedWithURL.assertValues([url])
  }
}
