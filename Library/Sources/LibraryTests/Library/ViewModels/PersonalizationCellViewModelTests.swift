@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PersonalizationCellViewModelTests: TestCase {
  private let notifyDelegateDismissButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateViewTapped = TestObserver<Void, Never>()

  private let vm: PersonalizationCellViewModelType = PersonalizationCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateDismissButtonTapped.observe(self.notifyDelegateDismissButtonTapped.observer)
    self.vm.outputs.notifyDelegateViewTapped.observe(self.notifyDelegateViewTapped.observer)
  }

  func testNotifyDelegateDismissButtonTapped() {
    self.notifyDelegateDismissButtonTapped.assertDidNotEmitValue()
    self.vm.inputs.dismissButtonTapped()
    self.notifyDelegateDismissButtonTapped.assertValueCount(1)
  }

  func testNotifyDelegateViewTapped() {
    self.notifyDelegateViewTapped.assertDidNotEmitValue()
    self.vm.inputs.cellTapped()
    self.notifyDelegateViewTapped.assertValueCount(1)
  }
}
