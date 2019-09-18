import Foundation
import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class RewardCellViewModelTests: TestCase {
  private let vm = RewardCellViewModel()

  private let scrollScrollViewToTop = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.scrollScrollViewToTop.observe(self.scrollScrollViewToTop.observer)
  }

  func testPrepareForReuse() {
    self.scrollScrollViewToTop.assertDidNotEmitValue()

    self.vm.inputs.prepareForReuse()

    self.scrollScrollViewToTop.assertValueCount(1)

    self.vm.inputs.prepareForReuse()

    self.scrollScrollViewToTop.assertValueCount(2)
  }
}
