@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

class DiscoveryProjectCategoryViewModelTests: XCTestCase {
  internal let vm = DiscoveryProjectCategoryViewModel()
  internal let categoryViewLabelText = TestObserver<String, Never>()
  internal let categoryImageName = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.categoryNameText.observe(self.categoryViewLabelText.observer)
    self.vm.outputs.categoryImageName.observe(self.categoryImageName.observer)
  }

  func testCategoryView() {
    self.vm.inputs.configureWith(name: "Art", imageNameString: "icon--compass")

    self.categoryImageName.assertValues(["icon--compass"])
    self.categoryViewLabelText.assertValue("Art")
  }
}
