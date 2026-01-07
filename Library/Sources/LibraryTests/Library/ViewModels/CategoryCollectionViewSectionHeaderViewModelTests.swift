@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategoryCollectionViewSectionHeaderViewModelTests: TestCase {
  private let text = TestObserver<String, Never>()

  private let vm: CategoryCollectionViewSectionHeaderViewModelType
    = CategoryCollectionViewSectionHeaderViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.text.observe(self.text.observer)
  }

  func testText() {
    self.text.assertDidNotEmitValue()
    self.vm.inputs.configure(with: "Ceramics")
    self.text.assertValues(["Ceramics"])
  }
}
