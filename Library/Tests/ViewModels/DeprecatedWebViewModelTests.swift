import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import Prelude

final class DeprecatedWebViewModelTests: TestCase {
  private let vm: DeprecatedWebViewModelType = DeprecatedWebViewModel()

  private let loadingOverlayIsHidden = TestObserver<Bool, NoError>()
  private let loadingOverlayIsAnimated = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadingOverlayIsHiddenAndAnimate.map(first)
      .observe(self.loadingOverlayIsHidden.observer)
    self.vm.outputs.loadingOverlayIsHiddenAndAnimate.map(second)
      .observe(self.loadingOverlayIsAnimated.observer)
  }

  func testLoadingOverlay_TypicalLoadingLifecycle() {
    self.vm.inputs.viewDidLoad()

    self.loadingOverlayIsHidden.assertValues([true])
    self.loadingOverlayIsAnimated.assertValues([false])

    self.vm.inputs.webViewDidStartLoad()

    self.loadingOverlayIsHidden.assertValues([true, false])
    self.loadingOverlayIsAnimated.assertValues([false, true])

    self.vm.inputs.webViewDidFinishLoad()

    self.loadingOverlayIsHidden.assertValues([true, false, true])
    self.loadingOverlayIsAnimated.assertValues([false, true, true])
  }

  func testLoadingOverlay_LoadingLifecycleWithInterruption() {
    self.vm.inputs.viewDidLoad()

    self.loadingOverlayIsHidden.assertValues([true])
    self.loadingOverlayIsAnimated.assertValues([false])

    self.vm.inputs.webViewDidStartLoad()

    self.loadingOverlayIsHidden.assertValues([true, false])
    self.loadingOverlayIsAnimated.assertValues([false, true])

    // An interruption error.
    self.vm.inputs.webViewDidFail(withError: NSError(domain: "", code: 102, userInfo: nil))

    self.loadingOverlayIsHidden.assertValues([true, false])
    self.loadingOverlayIsAnimated.assertValues([false, true])

    self.vm.inputs.webViewDidFinishLoad()

    self.loadingOverlayIsHidden.assertValues([true, false, true])
    self.loadingOverlayIsAnimated.assertValues([false, true, true])
  }

  func testLoadingOverlay_LoadingLifecycleWithFailure() {
    self.vm.inputs.viewDidLoad()

    self.loadingOverlayIsHidden.assertValues([true])
    self.loadingOverlayIsAnimated.assertValues([false])

    self.vm.inputs.webViewDidStartLoad()

    self.loadingOverlayIsHidden.assertValues([true, false])
    self.loadingOverlayIsAnimated.assertValues([false, true])

    // A legit error
    self.vm.inputs.webViewDidFail(withError: NSError(domain: "", code: 42, userInfo: nil))

    self.loadingOverlayIsHidden.assertValues([true, false, true])
    self.loadingOverlayIsAnimated.assertValues([false, true, true])
  }
}
