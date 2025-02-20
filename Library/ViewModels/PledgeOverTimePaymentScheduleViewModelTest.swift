import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeOverTimePaymentScheduleViewModelTest: TestCase {
  // MARK: Properties

  private var vm: PledgeOverTimePaymentScheduleViewModelType = PledgeOverTimePaymentScheduleViewModel()

  private var collapsed = TestObserver<Bool, Never>()
  private var paymentScheduleItems = TestObserver<[PLOTPaymentScheduleItem], Never>()

  private lazy var increments = mockPaymentIncrements()
  private lazy var expectedItems = {
    self.increments.map { PLOTPaymentScheduleItem(with: $0) }
  }()

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.vm.outputs.collapsed
      .observe(self.collapsed.observer)

    self.vm.outputs.paymentScheduleItems
      .observe(self.paymentScheduleItems.observer)
  }

  // MARK: Test cases

  func testCollapseToggle_Collapsed() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: self.increments)
    self.vm.inputs.collapseToggle()
    self.vm.inputs.collapseToggle()

    self.collapsed.assertValues([false, true])
    self.paymentScheduleItems.assertValue(self.expectedItems)
  }

  func testCollapseToggle_Expanded() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: self.increments)
    self.vm.inputs.collapseToggle()

    self.collapsed.assertValues([false])
    self.paymentScheduleItems.assertValue(self.expectedItems)
  }
}
