import XCTest
import Prelude
import Result
import Library
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

class DiscoveryProjectCategoryViewModelTests: XCTestCase {
    internal let vm = DiscoveryProjectCategoryViewModel()
    internal let categoryViewLabelText = TestObserver<String, NoError>()
    internal let categoryImage = TestObserver<UIImage?, NoError>()

    override func setUp() {
      super.setUp()

      self.vm.outputs.categoryNameText.observe(self.categoryViewLabelText.observer)
      self.vm.outputs.categoryImage.observe(self.categoryImage.observer)
    }

    func testCategoryImageIsNil_IfImageStringIsNilImage() {
      self.vm.inputs.configureWith(name: "Art", imageNameString: "icon-some")

      self.categoryImage.assertValue(nil)
      self.categoryViewLabelText.assertValue("Art")
    }

  func testCategoryView() {
    self.vm.inputs.configureWith(name: "Art", imageNameString: "icon--compass")

    self.categoryImage.assertValue(UIImage(named: "icon--compass"))
    self.categoryViewLabelText.assertValue("Art")
  }
}
