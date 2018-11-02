import Result
import Prelude
import XCTest
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers

final class LoadingBarButtonItemViewModelTests: TestCase {
  private let vm: LoadingBarButtonItemViewModelType = LoadingBarButtonItemViewModel()

  private let activityIndicatorIsLoadingObserver = TestObserver<Bool, NoError>()
  private let titleButtonIsEnabledObserver = TestObserver<Bool, NoError>()
  private let titleButtonIsHiddenObserver = TestObserver<Bool, NoError>()
  private let titleButtonTextObserver = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activityIndicatorIsLoading.observe(activityIndicatorIsLoadingObserver.observer)
    self.vm.outputs.titleButtonIsEnabled.observe(titleButtonIsEnabledObserver.observer)
    self.vm.outputs.titleButtonIsHidden.observe(titleButtonIsHiddenObserver.observer)
    self.vm.outputs.titleButtonText.observe(titleButtonTextObserver.observer)
  }

  func testSetIsEnabled() {
    self.vm.inputs.setIsEnabled(isEnabled: true)

    self.titleButtonIsEnabledObserver.assertValues([true])

    self.vm.inputs.setIsEnabled(isEnabled: false)

    self.titleButtonIsEnabledObserver.assertValues([true, false])
  }

  func testSetTitle() {
    self.vm.inputs.setTitle(title: "Hello")

    self.titleButtonTextObserver.assertValue("Hello")
  }

  func testAnimating() {
    self.vm.inputs.setAnimating(isAnimating: true)

    self.activityIndicatorIsLoadingObserver.assertValues([true])
    self.titleButtonIsHiddenObserver.assertValues([true])

    self.vm.inputs.setAnimating(isAnimating: false)

    self.activityIndicatorIsLoadingObserver.assertValues([true, false])
    self.titleButtonIsHiddenObserver.assertValues([true, false])
  }
}
