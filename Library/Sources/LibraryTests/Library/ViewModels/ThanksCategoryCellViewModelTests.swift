@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class ThanksCategoryCellViewModelTests: TestCase {
  private let notifyDelegateToGoToDiscovery = TestObserver<KsApi.Category, Never>()
  private let seeAllProjectCategoryTitle = TestObserver<String, Never>()
  private let vm = ThanksCategoryCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.notifyDelegateToGoToDiscovery.observe(self.notifyDelegateToGoToDiscovery.observer)
    self.vm.seeAllProjectCategoryTitle.observe(self.seeAllProjectCategoryTitle.observer)
  }

  func testNotifyDelegate() {
    let category = Category.template

    self.vm.inputs.configureWith(category: category)
    self.notifyDelegateToGoToDiscovery.assertDidNotEmitValue()
    self.vm.inputs.seeAllProjectsButtonTapped()
    self.notifyDelegateToGoToDiscovery.assertDidEmitValue()
  }

  func testSeeAllProjectCategoryButtonTitle() {
    let category = Category.template
      |> Category.lens.name .~ "Art"

    self.vm.inputs.configureWith(category: category)
    self.seeAllProjectCategoryTitle.assertValues(["See all Art projects"])
  }
}
