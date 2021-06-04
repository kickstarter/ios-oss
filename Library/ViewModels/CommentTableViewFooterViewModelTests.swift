@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class CommentTableViewFooterViewModelTests: TestCase {
  private let vm: CommentTableViewFooterViewModelType = CommentTableViewFooterViewModel()

  private let shouldShowActivityIndicator = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.shouldShowActivityIndicator.observe(self.shouldShowActivityIndicator.observer)
  }

  func testShouldShowActivityIndicator_Configure_True() {
    self.shouldShowActivityIndicator.assertDidNotEmitValue()

    self.vm.inputs.configure(with: true)

    self.shouldShowActivityIndicator.assertValues([true], "loading indicator value is emitted")
  }

  func testShouldShowActivityIndicator_Configure_False() {
    self.shouldShowActivityIndicator.assertDidNotEmitValue()

    self.vm.inputs.configure(with: false)

    self.shouldShowActivityIndicator.assertValues([false], "loading indicator value is emitted")
  }
}
