@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ViewMoreRepliesCellViewModelTests: TestCase {
  let vm: ViewMoreRepliesCellViewModelType = ViewMoreRepliesCellViewModel()

  private let notifyDelegateToGoToDiscovery = TestObserver<KsApi.Category, Never>()
  private let seeAllProjectCategoryTitle = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateToGoToDiscovery.observe(self.notifyDelegateToGoToDiscovery.observer)
    self.vm.outputs.seeAllProjectCategoryTitle.observe(self.seeAllProjectCategoryTitle.observer)
  }

  func testOutput_NotifyDelegateToGoToDiscovery() {
    self.vm.inputs.configureWith(category: .games)

    self.scheduler.advance()

    self.vm.inputs.seeAllProjectsButtonTapped()

    self.notifyDelegateToGoToDiscovery.assertValue(.games)
  }

  func testOutput_SeeAllProjectCategoryTitle() {
    self.vm.inputs.configureWith(category: .games)

    self.scheduler.advance()

    self.vm.inputs.seeAllProjectsButtonTapped()

    self.seeAllProjectCategoryTitle.assertValue("See all Games projects")
  }
}
