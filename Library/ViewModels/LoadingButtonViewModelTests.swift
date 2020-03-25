@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class LoadingButtonViewModelTests: TestCase {
  private let vm: LoadingButtonViewModelType = LoadingButtonViewModel()

  private let isUserInteractionEnabled = TestObserver<Bool, Never>()
  private let startLoading = TestObserver<Void, Never>()
  private let stopLoading = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.isUserInteractionEnabled.observe(self.isUserInteractionEnabled.observer)
    self.vm.outputs.startLoading.observe(self.startLoading.observer)
    self.vm.outputs.stopLoading.observe(self.stopLoading.observer)
  }

  func testIsLoading() {
    self.vm.inputs.isLoading(true)
    self.isUserInteractionEnabled.assertValues([false])
    self.startLoading.assertValueCount(1)
    self.stopLoading.assertValueCount(0)

    self.vm.inputs.isLoading(false)
    self.isUserInteractionEnabled.assertValues([false, true])
    self.startLoading.assertValueCount(1)
    self.stopLoading.assertValueCount(1)
  }
}
