@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeAmountViewModelTests: TestCase {
  private let vm: PledgeAmountViewModelType = PledgeAmountViewModel()

  private let amountIsValid = TestObserver<Bool, Never>()
  private let amountValue = TestObserver<Double, Never>()
  private let currency = TestObserver<String, Never>()
  private let doneButtonIsEnabled = TestObserver<Bool, Never>()
  private let generateSelectionFeedback = TestObserver<Void, Never>()
  private let generateNotificationWarningFeedback = TestObserver<Void, Never>()
  private let labelTextColor = TestObserver<UIColor, Never>()
  private let stepperMaxValue = TestObserver<Double, Never>()
  private let stepperMinValue = TestObserver<Double, Never>()
  private let stepperStepValue = TestObserver<Double, Never>()
  private let stepperValue = TestObserver<Double, Never>()
  private let textFieldIsFirstResponder = TestObserver<Bool, Never>()
  private let textFieldTextColor = TestObserver<UIColor?, Never>()
  private let textFieldValue = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amount.map(second).observe(self.amountIsValid.observer)
    self.vm.outputs.amount.map(first).observe(self.amountValue.observer)
    self.vm.outputs.currency.observe(self.currency.observer)
    self.vm.outputs.doneButtonIsEnabled.observe(self.doneButtonIsEnabled.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateNotificationWarningFeedback.observe(
      self.generateNotificationWarningFeedback.observer
    )
    self.vm.outputs.labelTextColor.observe(self.labelTextColor.observer)
    self.vm.outputs.stepperMaxValue.observe(self.stepperMaxValue.observer)
    self.vm.outputs.stepperMinValue.observe(self.stepperMinValue.observer)
    self.vm.outputs.stepperStepValue.observe(self.stepperStepValue.observer)
    self.vm.outputs.stepperValue.observe(self.stepperValue.observer)
    self.vm.outputs.textFieldIsFirstResponder.observe(self.textFieldIsFirstResponder.observer)
    self.vm.outputs.textFieldTextColor.observe(self.textFieldTextColor.observer)
    self.vm.outputs.textFieldValue.observe(self.textFieldValue.observer)
  }

  func testAmountCurrencyAndStepper_FromBacking() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    self.vm.inputs.configureWith(project: project, reward: Reward.postcards)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([700])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(PledgeAmountStepperConstants.min)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperStepValue.assertValue(6)
    self.stepperValue.assertValues([6, 700])
    self.textFieldValue.assertValues(["700"])
  }

  func testAmountCurrencyAndStepper_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([1])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(PledgeAmountStepperConstants.min)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperStepValue.assertValue(1)
    self.stepperValue.assertValues([1])
    self.textFieldValue.assertValues(["1"])
  }

  func testAmountCurrencyAndStepper_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.mx

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([10])
    self.currency.assertValues(["MX$"])
    self.stepperMinValue.assertValue(PledgeAmountStepperConstants.min)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperStepValue.assertValue(10)
    self.stepperValue.assertValues([10])
    self.textFieldValue.assertValues(["10"])
  }

  func testAmountCurrencyAndStepper_Country_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.us
      |> Project.Country.lens.minPledge .~ nil

    let project = Project.template
      |> Project.lens.country .~ country

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([1])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(PledgeAmountStepperConstants.min)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperStepValue.assertValue(1)
    self.stepperValue.assertValues([1])
    self.textFieldValue.assertValues(["1"])
  }

  func testAmountCurrencyAndStepper_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([10])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(PledgeAmountStepperConstants.min)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperStepValue.assertValue(10)
    self.stepperValue.assertValues([10])
    self.textFieldValue.assertValues(["10"])
  }

  func testAmountCurrencyAndStepper_Reward_Minimum_Custom() {
    let project = Project.template
      |> Project.lens.country .~ .jp

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([200])
    self.currency.assertValues(["¥"])
    self.stepperMinValue.assertValue(PledgeAmountStepperConstants.min)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperStepValue.assertValue(200)
    self.stepperValue.assertValues([200])
    self.textFieldValue.assertValues(["200"])
  }

  func testDoneButtonIsEnabled_Stepper_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(2)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(1)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.hk

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(75_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(9)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(1)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_Country_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(300)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(100)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("2")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.hk

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("75000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("9")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("10")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_Country_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("100")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("10")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("2")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.hk

    self.vm.inputs.configureWith(project: project, reward: Reward.noReward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(75_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("9")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_Country_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: .template, reward: reward)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(100)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
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
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testGenerateSelectionFeedback() {
    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.generateSelectionFeedback.assertDidNotEmitValue()

    self.vm.inputs.stepperValueChanged(11)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(PledgeAmountStepperConstants.max)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(12)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(0)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(20)
    self.generateSelectionFeedback.assertValueCount(3)
  }

  func testGenerateNotificationWarningFeedback() {
    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.generateNotificationWarningFeedback.assertDidNotEmitValue()

    self.vm.inputs.stepperValueChanged(11)
    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(PledgeAmountStepperConstants.max)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(12)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(0)
    self.generateNotificationWarningFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(11)
    self.generateNotificationWarningFeedback.assertValueCount(2)
  }

  func testLabelTextColor() {
    let green = UIColor.ksr_green_500
    let red = UIColor.ksr_red_400

    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.labelTextColor.assertValues([green])

    self.vm.inputs.stepperValueChanged(2)
    self.labelTextColor.assertValues([green])

    self.vm.inputs.stepperValueChanged(100_000)
    self.labelTextColor.assertValues([green, red])

    self.vm.inputs.stepperValueChanged(10_000)
    self.labelTextColor.assertValues([green, red, green])

    self.vm.inputs.stepperValueChanged(0)
    self.labelTextColor.assertValues([green, red, green, red])

    self.vm.inputs.stepperValueChanged(1)
    self.labelTextColor.assertValues([green, red, green, red, green])
  }

  func testStepperValueChangesWithTextFieldInput() {
    let maxValue = PledgeAmountStepperConstants.max

    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.stepperValue.assertValues([10])

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([10, 11])

    self.vm.inputs.textFieldValueChanged("16")
    self.stepperValue.assertValues([10, 11, 16])

    self.vm.inputs.textFieldValueChanged(String(format: "%.0f", maxValue))
    self.stepperValue.assertValues([10, 11, 16, maxValue])

    self.vm.inputs.textFieldValueChanged("0")
    self.stepperValue.assertValues([10, 11, 16, maxValue, 0])

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([10, 11, 16, maxValue, 0, 11])
  }

  func testTextFieldIsFirstResponder() {
    self.vm.inputs.doneButtonTapped()

    self.textFieldIsFirstResponder.assertValue(false)
  }

  func testNilInputReturnsZero() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValue(10)

    self.vm.inputs.textFieldValueChanged("11")
    self.amountIsValid.assertValues([true, true])
    self.amountValue.assertValues([10, 11])

    self.vm.inputs.textFieldValueChanged("")
    self.amountIsValid.assertValues([true, true, false])
    self.amountValue.assertValues([10, 11, 0])

    self.vm.inputs.textFieldValueChanged("5")
    self.amountIsValid.assertValues([true, true, false, false])
    self.amountValue.assertValues([10, 11, 0, 5])

    self.vm.inputs.textFieldValueChanged(nil)
    self.amountIsValid.assertValues([true, true, false, false, false])
    self.amountValue.assertValues([10, 11, 0, 5, 0])
  }

  func testTextFieldDidEndEditing() {
    let maxValue = PledgeAmountStepperConstants.max
    let maxValueFormatted = String(format: "%.0f", maxValue)

    self.vm.inputs.configureWith(project: .template, reward: .template)
    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([10])
    self.textFieldValue.assertValues(["10"])

    self.vm.inputs.textFieldDidEndEditing(nil)
    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([10])
    self.textFieldValue.assertValues(["10"])

    self.vm.inputs.textFieldDidEndEditing("16")
    self.amountIsValid.assertValues([true, true])
    self.amountValue.assertValues([10, 16])
    self.textFieldValue.assertValues(["10", "16"])

    self.vm.inputs.textFieldDidEndEditing(String(maxValue))
    self.amountIsValid.assertValues([true, true, false])
    self.amountValue.assertValues([10, 16, maxValue])
    self.textFieldValue.assertValues(["10", "16", maxValueFormatted])

    self.vm.inputs.textFieldDidEndEditing("0")
    self.amountIsValid.assertValues([true, true, false, false])
    self.amountValue.assertValues([10, 16, maxValue, 0])
    self.textFieldValue.assertValues(["10", "16", maxValueFormatted, "0"])

    self.vm.inputs.textFieldDidEndEditing("17")
    self.amountIsValid.assertValues([true, true, false, false, true])
    self.amountValue.assertValues([10, 16, maxValue, 0, 17])
    self.textFieldValue.assertValues(["10", "16", maxValueFormatted, "0", "17"])

    self.vm.inputs.textFieldDidEndEditing("")
    self.amountIsValid.assertValues([true, true, false, false, true])
    self.amountValue.assertValues([10, 16, maxValue, 0, 17])
    self.textFieldValue.assertValues(["10", "16", maxValueFormatted, "0", "17"])
  }

  func testTextFieldTextColor() {
    let green = UIColor.ksr_green_500
    let red = UIColor.ksr_red_400

    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward)

    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.stepperValueChanged(2)
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.stepperValueChanged(100_000)
    self.textFieldTextColor.assertValues([green, red])

    self.vm.inputs.stepperValueChanged(10_000)
    self.textFieldTextColor.assertValues([green, red, green])

    self.vm.inputs.stepperValueChanged(0)
    self.textFieldTextColor.assertValues([green, red, green, red])

    self.vm.inputs.stepperValueChanged(1)
    self.textFieldTextColor.assertValues([green, red, green, red, green])
  }

  // swiftlint:disable line_length
  func testTextFieldValueChangedRounding() {
    let green = UIColor.ksr_green_500
    let red = UIColor.ksr_red_400

    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amountIsValid.assertValues([true])
    self.amountValue.assertValues([10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10")
    self.amountIsValid.assertValues([true, true])
    self.amountValue.assertValues([10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.")
    self.amountIsValid.assertValues([true, true, true])
    self.amountValue.assertValues([10, 10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.0")
    self.amountIsValid.assertValues([true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.00")
    self.amountIsValid.assertValues([true, true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.01")
    self.amountIsValid.assertValues([true, true, true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10, 10.01])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.010")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01, 10.01])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10, 10.01])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.0100")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01, 10.01, 10.01])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10, 10.01])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.019")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10, 10.01, 10.02])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.0194444444")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true, true])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([10, 10.01, 10.02])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("9.999")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true, true, false])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02, 10])
    self.doneButtonIsEnabled.assertValues([true, false])
    self.labelTextColor.assertValues([green, red])
    self.stepperValue.assertValues([10, 10.01, 10.02, 10])
    self.textFieldTextColor.assertValues([green, red])

    self.vm.inputs.textFieldValueChanged("9.99")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true, true, false, false])
    self.amountValue.assertValues([10, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02, 10, 9.99])
    self.doneButtonIsEnabled.assertValues([true, false])
    self.labelTextColor.assertValues([green, red])
    self.stepperValue.assertValues([10, 10.01, 10.02, 10, 9.99])
    self.textFieldTextColor.assertValues([green, red])
  }

  func testTextFieldDidEndEditingRoundingAndTruncation() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.textFieldValue.assertValues(["10"])

    self.vm.inputs.textFieldDidEndEditing("10.")
    self.textFieldValue.assertValues(["10", "10"])

    self.vm.inputs.textFieldDidEndEditing("10.0")
    self.textFieldValue.assertValues(["10", "10", "10"])

    self.vm.inputs.textFieldDidEndEditing("10.00")
    self.textFieldValue.assertValues(["10", "10", "10", "10"])

    self.vm.inputs.textFieldDidEndEditing("10.01")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01"])

    self.vm.inputs.textFieldDidEndEditing("10.010")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01", "10.01"])

    self.vm.inputs.textFieldDidEndEditing("10.0100")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01", "10.01", "10.01"])

    self.vm.inputs.textFieldDidEndEditing("10.019")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01", "10.01", "10.01", "10.02"])

    self.vm.inputs.textFieldDidEndEditing("10.0194444444")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01", "10.01", "10.01", "10.02", "10.02"])

    self.vm.inputs.textFieldDidEndEditing("9.999")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01", "10.01", "10.01", "10.02", "10.02", "10"])

    self.vm.inputs.textFieldDidEndEditing("9.99")
    self.textFieldValue.assertValues(["10", "10", "10", "10", "10.01", "10.01", "10.01", "10.02", "10.02", "10", "9.99"])
  }

  // swiftlint:enable line_length
}
