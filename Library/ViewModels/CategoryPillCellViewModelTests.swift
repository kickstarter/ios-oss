@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategoryPillCellViewModelTests: TestCase {
  private let buttonTitle = TestObserver<String, Never>()
  private let isSelected = TestObserver<Bool, Never>()
  private let notifyDelegatePillCellTapped = TestObserver<IndexPath, Never>()

  private let vm: CategoryPillCellViewModelType = CategoryPillCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.buttonTitle.observe(self.buttonTitle.observer)
    self.vm.outputs.isSelected.observe(self.isSelected.observer)
    self.vm.outputs.notifyDelegatePillCellTapped.observe(self.notifyDelegatePillCellTapped.observer)
  }

  func testButtonTitle() {
    let indexPath = IndexPath(item: 0, section: 0)

    self.buttonTitle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: ("title", indexPath))

    self.buttonTitle.assertValues(["title"])
  }

  func testIsSelected() {
    let indexPath = IndexPath(item: 0, section: 0)

    self.isSelected.assertDidNotEmitValue()

    self.vm.inputs.configure(with: ("title", indexPath))

    self.vm.inputs.setIsSelected(selected: true)

    self.isSelected.assertValues([true])

    self.vm.inputs.setIsSelected(selected: false)

    self.isSelected.assertValues([true, false])
  }

  func testNotifyDelegatePillCellTapped() {
    let indexPath = IndexPath(item: 0, section: 0)

    self.notifyDelegatePillCellTapped.assertDidNotEmitValue()

    self.vm.inputs.configure(with: ("title", indexPath))
    self.vm.inputs.pillCellTapped()

    self.notifyDelegatePillCellTapped.assertValues([indexPath])
  }
}
