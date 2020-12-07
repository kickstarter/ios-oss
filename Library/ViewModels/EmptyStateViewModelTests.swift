@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class EmptyStateViewModelTests: TestCase {
  private let vm: EmptyStateViewModelType = EmptyStateViewModel()

  private let bodyLabelHidden = TestObserver<Bool, Never>()
  private let bodyLabelText = TestObserver<String, Never>()
  private let bodyLabelTextColor = TestObserver<UIColor, Never>()
  private let imageName = TestObserver<String?, Never>()
  private let leftRightMargins = TestObserver<CGFloat, Never>()
  private let titleLabelHidden = TestObserver<Bool, Never>()
  private let titleLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.bodyLabelHidden.observe(self.bodyLabelHidden.observer)
    self.vm.outputs.bodyLabelText.observe(self.bodyLabelText.observer)
    self.vm.outputs.bodyLabelTextColor.observe(self.bodyLabelTextColor.observer)
    self.vm.outputs.imageName.observe(self.imageName.observer)
    self.vm.outputs.leftRightMargins.observe(self.leftRightMargins.observer)
    self.vm.outputs.titleLabelHidden.observe(self.titleLabelHidden.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
  }

  func testErrorPullToRefreshState() {
    self.bodyLabelHidden.assertDidNotEmitValue()
    self.bodyLabelText.assertDidNotEmitValue()
    self.bodyLabelTextColor.assertDidNotEmitValue()
    self.imageName.assertDidNotEmitValue()
    self.leftRightMargins.assertDidNotEmitValue()
    self.titleLabelHidden.assertDidNotEmitValue()
    self.titleLabelText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .errorPullToRefresh)

    self.bodyLabelHidden.assertValues([false])
    self.bodyLabelText.assertValues(["Something went wrong—pull to refresh."])
    self.bodyLabelTextColor.assertValues([.ksr_support_700])
    self.imageName.assertValues(["icon-exclamation"])
    self.leftRightMargins.assertValues([Styles.grid(10)])
    self.titleLabelHidden.assertValues([true])
    self.titleLabelText.assertValues([""])
  }

  func testAddOnsUnavailableState() {
    self.bodyLabelHidden.assertDidNotEmitValue()
    self.bodyLabelText.assertDidNotEmitValue()
    self.bodyLabelTextColor.assertDidNotEmitValue()
    self.imageName.assertDidNotEmitValue()
    self.leftRightMargins.assertDidNotEmitValue()
    self.titleLabelHidden.assertDidNotEmitValue()
    self.titleLabelText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .addOnsUnavailable)

    self.bodyLabelHidden.assertValues([false])
    self.bodyLabelText.assertValues(["Change your shipping location or skip add-ons to continue."])
    self.bodyLabelTextColor.assertValues([.ksr_support_400])
    self.imageName.assertValues(["icon-globe"])
    self.leftRightMargins.assertValues([Styles.grid(3)])
    self.titleLabelHidden.assertValues([false])
    self.titleLabelText.assertValues(["Add-ons unavailable"])
  }
}
