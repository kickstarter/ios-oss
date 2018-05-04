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
    
    func testCategoryNameImage() {
      self.vm.inputs.updateCategoryName(name: "Art")
      self.vm.inputs.updateImageString(imageString: "icon-some")
      
      self.categoryImage.assertValue(nil)
      self.categoryViewLabelText.assertValue("Art")
    }
}
