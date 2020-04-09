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
  private let notifyDelegatePillCellTappedIndexPath = TestObserver<IndexPath, Never>()
  private let notifyDelegatePillCellTappedCategory = TestObserver<KsApi.Category, Never>()

  private let vm: CategoryPillCellViewModelType = CategoryPillCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.buttonTitle.observe(self.buttonTitle.observer)
    self.vm.outputs.isSelected.observe(self.isSelected.observer)
    self.vm.outputs.notifyDelegatePillCellTapped.map(first)
      .observe(self.notifyDelegatePillCellTappedIndexPath.observer)
    self.vm.outputs.notifyDelegatePillCellTapped.map(second)
      .observe(self.notifyDelegatePillCellTappedCategory.observer)
  }

  func testButtonTitle() {
    let indexPath = IndexPath(item: 0, section: 0)

    self.buttonTitle.assertDidNotEmitValue()

    self.vm.inputs.configure(with: ("title", .art, indexPath))

    self.buttonTitle.assertValues(["title"])
  }

  func testIsSelected() {
    let indexPath = IndexPath(item: 0, section: 0)

    self.isSelected.assertDidNotEmitValue()

    self.vm.inputs.configure(with: ("title", .art, indexPath))

    self.vm.inputs.setIsSelected(selected: true)

    self.isSelected.assertValues([true])

    self.vm.inputs.setIsSelected(selected: false)

    self.isSelected.assertValues([true, false])
  }

  func testNotifyDelegatePillCellTapped() {
    let indexPath = IndexPath(item: 0, section: 0)

    self.notifyDelegatePillCellTappedIndexPath.assertDidNotEmitValue()
    self.notifyDelegatePillCellTappedCategory.assertDidNotEmitValue()

    self.vm.inputs.configure(with: ("title", .art, indexPath))
    self.vm.inputs.pillCellTapped()

    self.notifyDelegatePillCellTappedIndexPath.assertValues([indexPath])
    self.notifyDelegatePillCellTappedCategory.assertValues([.art])
  }
}
