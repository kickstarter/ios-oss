@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class CommentTableViewFooterViewModelTests: TestCase {
  private let vm: CommentTableViewFooterViewModelType = CommentTableViewFooterViewModel()

  private let shouldStartLoaderIndicator = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.shouldStartLoaderIndicator.observe(self.shouldStartLoaderIndicator.observer)
  }

  func testShouldStartLoadingIndicator() {
    self.shouldStartLoaderIndicator.assertDidNotEmitValue()

    self.vm.inputs.configure(with: true)

    self.shouldStartLoaderIndicator.assertValues([true], "loading indicator value is emitted")

    self.vm.inputs.configure(with: false)

    self.shouldStartLoaderIndicator.assertValues([true, false], "loading indicator value is emitted")
  }
}
