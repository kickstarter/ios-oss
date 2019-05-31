import Prelude
import XCTest
@testable import Library
import ReactiveExtensions_TestHelpers

final class LoadingBarButtonItemViewModelTests: TestCase {
  private let vm: LoadingBarButtonItemViewModelType = LoadingBarButtonItemViewModel()

  private let activityIndicatorIsLoading = TestObserver<Bool, Never>()
  private let titleButtonIsEnabled = TestObserver<Bool, Never>()
  private let titleButtonIsHidden = TestObserver<Bool, Never>()
  private let titleButtonText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorIsLoading.observe(activityIndicatorIsLoading.observer)
    self.vm.outputs.titleButtonIsEnabled.observe(titleButtonIsEnabled.observer)
    self.vm.outputs.titleButtonIsHidden.observe(titleButtonIsHidden.observer)
    self.vm.outputs.titleButtonText.observe(titleButtonText.observer)
  }

  func testSetIsEnabled() {
    self.vm.inputs.setIsEnabled(isEnabled: true)

    self.titleButtonIsEnabled.assertValues([true])

    self.vm.inputs.setIsEnabled(isEnabled: false)

    self.titleButtonIsEnabled.assertValues([true, false])
  }

  func testSetTitle() {
    self.vm.inputs.setTitle(title: "Hello")

    self.titleButtonText.assertValue("Hello")
  }

  func testAnimating() {
    self.vm.inputs.setAnimating(isAnimating: true)

    self.activityIndicatorIsLoading.assertValues([true])
    self.titleButtonIsHidden.assertValues([true])

    self.vm.inputs.setAnimating(isAnimating: false)

    self.activityIndicatorIsLoading.assertValues([true, false])
    self.titleButtonIsHidden.assertValues([true, false])
  }
}
