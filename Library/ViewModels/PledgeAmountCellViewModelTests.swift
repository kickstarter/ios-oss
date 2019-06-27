@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeAmountCellViewModelTests: TestCase {
  private let vm: PledgeAmountCellViewModelType = PledgeAmountCellViewModel()

  private let amountPrimitive = TestObserver<Double, Never>()
  private let currency = TestObserver<String, Never>()
  private let doneButtonIsEnabled = TestObserver<Bool, Never>()
  private let generateSelectionFeedback = TestObserver<Void, Never>()
  private let generateNotificationWarningFeedback = TestObserver<Void, Never>()
  private let stepperMaxValue = TestObserver<Double, Never>()
  private let stepperMinValue = TestObserver<Double, Never>()
  private let stepperStepValue = TestObserver<Double, Never>()
  private let stepperValue = TestObserver<Double, Never>()
  private let textFieldIsFirstResponder = TestObserver<Bool, Never>()
  private let textFieldValue = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountPrimitive.observe(self.amountPrimitive.observer)
    self.vm.outputs.currency.observe(self.currency.observer)
    self.vm.outputs.doneButtonIsEnabled.observe(self.doneButtonIsEnabled.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateNotificationWarningFeedback.observe(
      self.generateNotificationWarningFeedback.observer
    )
    self.vm.outputs.stepperMaxValue.observe(self.stepperMaxValue.observer)
    self.vm.outputs.stepperMinValue.observe(self.stepperMinValue.observer)
    self.vm.outputs.stepperStepValue.observe(self.stepperStepValue.observer)
    self.vm.outputs.stepperValue.observe(self.stepperValue.observer)
    self.vm.outputs.textFieldIsFirstResponder.observe(self.textFieldIsFirstResponder.observer)
    self.vm.outputs.textFieldValue.observe(self.textFieldValue.observer)
  }

  func testAmountCurrencyAndStepper_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.amountPrimitive.assertValues([1])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(1)
    self.stepperMaxValue.assertValue(10_000)
    self.stepperStepValue.assertValue(1)
    self.stepperValue.assertValue(1)
    self.textFieldValue.assertValues(["1"])
  }

  func testAmountCurrencyAndStepper_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.mx

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.amountPrimitive.assertValues([10])
    self.currency.assertValues(["MX$"])
    self.stepperMinValue.assertValue(10)
    self.stepperMinValue.assertValue(10)
    self.stepperMaxValue.assertValue(200_000)
    self.stepperStepValue.assertValue(10)
    self.stepperValue.assertValue(10)
    self.textFieldValue.assertValues(["10"])
  }

  func testAmountCurrencyAndStepper_Country_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.us
      |> Project.Country.lens.minPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.amountPrimitive.assertValues([1])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(1)
    self.stepperMaxValue.assertValue(10_000)
    self.stepperStepValue.assertValue(1)
    self.stepperValue.assertValue(1)
    self.textFieldValue.assertValues(["1"])
  }

  func testAmountCurrencyAndStepper_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amountPrimitive.assertValues([10])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(10)
    self.stepperMaxValue.assertValue(10_000)
    self.stepperStepValue.assertValue(10)
    self.stepperValue.assertValue(10)
    self.textFieldValue.assertValues(["10"])
  }

  func testAmountCurrencyAndStepper_Reward_Minimum_Custom() {
    let project = Project.template
      |> Project.lens.country .~ .jp

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.amountPrimitive.assertValues([200])
    self.currency.assertValues(["¥"])
    self.stepperMinValue.assertValue(200)
    self.stepperMaxValue.assertValue(1_200_000)
    self.stepperStepValue.assertValue(200)
    self.stepperValue.assertValue(200)
    self.textFieldValue.assertValues(["200"])
  }

  func testDoneButtonIsEnabled_Stepper_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(2)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(1)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.hk

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(75_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(9)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(2)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(1)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(300)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(100)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_DoesNotHaveMinMax_Reward_Minimum_Template() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_DoesNotHaveMinMax_Reward_Minimum_Custom() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(300)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("2")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.hk

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("75000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("9")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("10")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("2")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("100")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_DoesNotHaveMinMax_Reward_Minimum_Template() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("10")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_DoesNotHaveMinMax_Reward_Minimum_Custom() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("2")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.hk

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(75_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("9")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("2")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(100)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_DoesNotHaveMinMax_Reward_Minimum_Template() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_DoesNotHaveMinMax_Reward_Minimum_Custom() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testGenerateSelectionFeedback() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.vm.inputs.stepperValueChanged(11)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(10_001)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(12)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(10)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(20)
    self.generateSelectionFeedback.assertValueCount(3)
  }

  func testGenerateNotificationWarningFeedback() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(11)
    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(10_001)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(12)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(10)
    self.generateNotificationWarningFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(11)
    self.generateNotificationWarningFeedback.assertValueCount(2)
  }

  func testStepperValueChangesWithTextFieldInput() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperValue.assertValue(10)

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([10, 11])

    self.vm.inputs.textFieldValueChanged("16")
    self.stepperValue.assertValues([10, 11, 16])

    self.vm.inputs.textFieldValueChanged("10001")
    self.stepperValue.assertValues([10, 11, 16, 10_000])

    self.vm.inputs.textFieldValueChanged("1")
    self.stepperValue.assertValues([10, 11, 16, 10_000, 10])

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([10, 11, 16, 10_000, 10, 11])
  }

  func testTextFieldIsFirstResponder() {
    self.vm.inputs.doneButtonTapped()

    self.textFieldIsFirstResponder.assertValue(false)
  }

  func testNilInputReturnsZero() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amountPrimitive.assertValue(10)

    self.vm.inputs.textFieldValueChanged("11")
    self.amountPrimitive.assertValues([10, 11])

    self.vm.inputs.textFieldValueChanged("")
    self.amountPrimitive.assertValues([10, 11, 0])

    self.vm.inputs.textFieldValueChanged("5")
    self.amountPrimitive.assertValues([10, 11, 0, 5])

    self.vm.inputs.textFieldValueChanged(nil)
    self.amountPrimitive.assertValues([10, 11, 0, 5, 0])
  }

  func testTextFieldDidEndEditing() {
    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.amountPrimitive.assertValues([10])
    self.textFieldValue.assertValues(["10"])

    self.vm.inputs.textFieldDidEndEditing(nil)
    self.amountPrimitive.assertValues([10])
    self.textFieldValue.assertValues(["10"])

    self.vm.inputs.textFieldDidEndEditing("16")
    self.amountPrimitive.assertValues([10, 16])
    self.textFieldValue.assertValues(["10", "16"])

    self.vm.inputs.textFieldDidEndEditing("10001")
    self.amountPrimitive.assertValues([10, 16, 10_000])
    self.textFieldValue.assertValues(["10", "16", "10000"])

    self.vm.inputs.textFieldDidEndEditing("8")
    self.amountPrimitive.assertValues([10, 16, 10_000, 10])
    self.textFieldValue.assertValues(["10", "16", "10000", "10"])

    self.vm.inputs.textFieldDidEndEditing("17")
    self.amountPrimitive.assertValues([10, 16, 10_000, 10, 17])
    self.textFieldValue.assertValues(["10", "16", "10000", "10", "17"])

    self.vm.inputs.textFieldDidEndEditing("")
    self.amountPrimitive.assertValues([10, 16, 10_000, 10, 17, 10])
    self.textFieldValue.assertValues(["10", "16", "10000", "10", "17", "10"])
  }
}
