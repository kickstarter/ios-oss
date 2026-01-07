@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class CommentTableViewFooterViewModelTests: TestCase {
  private let vm: CommentTableViewFooterViewModelType = CommentTableViewFooterViewModel()

  private let activityIndicatorHidden = TestObserver<Bool, Never>()
  private let bottomInsetHeight = TestObserver<Int, Never>()
  private let retryButtonHidden = TestObserver<Bool, Never>()
  private let rootStackViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorHidden.observe(self.activityIndicatorHidden.observer)
    self.vm.outputs.bottomInsetHeight.observe(self.bottomInsetHeight.observer)
    self.vm.outputs.retryButtonHidden.observe(self.retryButtonHidden.observer)
    self.vm.outputs.rootStackViewHidden.observe(self.rootStackViewHidden.observer)
  }

  func testStates() {
    self.activityIndicatorHidden.assertDidNotEmitValue()
    self.bottomInsetHeight.assertDidNotEmitValue()
    self.retryButtonHidden.assertDidNotEmitValue()
    self.rootStackViewHidden.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .activity)

    self.activityIndicatorHidden.assertValues([false])
    self.bottomInsetHeight.assertValues([2])
    self.retryButtonHidden.assertValues([true])
    self.rootStackViewHidden.assertValues([false])

    self.vm.inputs.configure(with: .error)

    self.activityIndicatorHidden.assertValues([false, true])
    self.bottomInsetHeight.assertValues([2, 4])
    self.retryButtonHidden.assertValues([true, false])
    self.rootStackViewHidden.assertValues([false, false])

    self.vm.inputs.configure(with: .hidden)

    self.activityIndicatorHidden.assertValues([false, true, true])
    self.bottomInsetHeight.assertValues([2, 4, 2])
    self.retryButtonHidden.assertValues([true, false, true])
    self.rootStackViewHidden.assertValues([false, false, true])
  }
}
