import Foundation
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentPlansOptionViewModelTest: TestCase {
  // MARK: Properties

  private var vm: PledgePaymentPlansOptionViewModelType = PledgePaymentPlansOptionViewModel()

  private var checkmarkImageName = TestObserver<String, Never>()
  private var titleText = TestObserver<String?, Never>()
  private var subtitleText = TestObserver<String?, Never>()
  private var notifyDelegatePaymentPlanOptionSelected = TestObserver<PledgePaymentPlansType, Never>()

  // MARK: Const

  private let pledgeInFullTitle = "Pledge in full"
  private let pledgeOverTimeTitle = "Pledge Over Time"
  private let pledgeOverTimeSubtitle =
    "You will be charged for your pledge over four payments, at no extra cost."
  private let selectedImageName = "icon-payment-method-selected"
  private let unselectedImageName = "icon-payment-method-unselected"

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.vm.outputs.checkmarkImageName.observe(self.checkmarkImageName.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
    self.vm.outputs.notifyDelegatePaymentPlanOptionSelected
      .observe(self.notifyDelegatePaymentPlanOptionSelected.observer)
  }

  // MARK: Test cases

  func testPaymentPlanOption_PledgeinFull_Selected() {
    let data = PledgePaymentPlanOptionData(type: .pledgeInFull, selectedType: .pledgeInFull)
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeInFullTitle)
    self.subtitleText.assertValue(nil)
    self.checkmarkImageName.assertValue(self.selectedImageName)
  }

  func testPaymentPlanOption_PledgeinFull_Unselected() {
    let data = PledgePaymentPlanOptionData(type: .pledgeInFull, selectedType: .pledgeOverTime)
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeInFullTitle)
    self.subtitleText.assertValue(nil)
    self.checkmarkImageName.assertValue(self.unselectedImageName)
  }

  func testPaymentPlanOption_PledgeOverTime_Selected() {
    let data = PledgePaymentPlanOptionData(type: .pledgeOverTime, selectedType: .pledgeOverTime)
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeOverTimeTitle)
    self.subtitleText.assertValue(self.pledgeOverTimeSubtitle)

    self.checkmarkImageName.assertValue(self.selectedImageName)
  }

  func testPaymentPlanOption_PledgeOverTime_Unselected() {
    let data = PledgePaymentPlanOptionData(type: .pledgeOverTime, selectedType: .pledgeInFull)
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeOverTimeTitle)
    self.subtitleText.assertValue(self.pledgeOverTimeSubtitle)

    self.checkmarkImageName.assertValue(self.unselectedImageName)
  }

  func testPaymentPlanOption_OptionTapped() {
    let data = PledgePaymentPlanOptionData(type: .pledgeOverTime, selectedType: .pledgeInFull)
    self.vm.inputs.configureWith(data: data)
    self.vm.inputs.optionTapped()
    self.notifyDelegatePaymentPlanOptionSelected.assertValue(.pledgeOverTime)
  }
}
