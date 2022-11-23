@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeAmountViewModelTests: TestCase {
  private let vm: PledgeAmountViewModelType = PledgeAmountViewModel()

  private let amountIsValid = TestObserver<Bool, Never>()
  private let amountMax = TestObserver<Double, Never>()
  private let amountMin = TestObserver<Double, Never>()
  private let amountValue = TestObserver<Double, Never>()
  private let currency = TestObserver<String, Never>()
  private let doneButtonIsEnabled = TestObserver<Bool, Never>()
  private let generateSelectionFeedback = TestObserver<Void, Never>()
  private let generateNotificationWarningFeedback = TestObserver<Void, Never>()
  private let labelTextColor = TestObserver<UIColor, Never>()
  private let maxPledgeAmountErrorLabelIsHidden = TestObserver<Bool, Never>()
  private let maxPledgeAmountErrorLabelText = TestObserver<String, Never>()
  private let plusSignLabelHidden = TestObserver<Bool, Never>()
  private let stepperMaxValue = TestObserver<Double, Never>()
  private let stepperMinValue = TestObserver<Double, Never>()
  private let stepperValue = TestObserver<Double, Never>()
  private let subTitleLabelHidden = TestObserver<Bool, Never>()
  private let textFieldIsFirstResponder = TestObserver<Bool, Never>()
  private let textFieldTextColor = TestObserver<UIColor?, Never>()
  private let textFieldValue = TestObserver<String, Never>()
  private let titleLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateAmountUpdated.map { $0.isValid }.observe(self.amountIsValid.observer)
    self.vm.outputs.notifyDelegateAmountUpdated.map { $0.max }.observe(self.amountMax.observer)
    self.vm.outputs.notifyDelegateAmountUpdated.map { $0.min }.observe(self.amountMin.observer)
    self.vm.outputs.notifyDelegateAmountUpdated.map { $0.amount }.observe(self.amountValue.observer)
    self.vm.outputs.currency.observe(self.currency.observer)
    self.vm.outputs.doneButtonIsEnabled.observe(self.doneButtonIsEnabled.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateNotificationWarningFeedback.observe(
      self.generateNotificationWarningFeedback.observer
    )
    self.vm.outputs.labelTextColor.observe(self.labelTextColor.observer)
    self.vm.outputs.maxPledgeAmountErrorLabelIsHidden.observe(
      self.maxPledgeAmountErrorLabelIsHidden.observer
    )
    self.vm.outputs.maxPledgeAmountErrorLabelText.observe(
      self.maxPledgeAmountErrorLabelText.observer
    )
    self.vm.outputs.plusSignLabelHidden.observe(self.plusSignLabelHidden.observer)
    self.vm.outputs.stepperMaxValue.observe(self.stepperMaxValue.observer)
    self.vm.outputs.stepperMinValue.observe(self.stepperMinValue.observer)
    self.vm.outputs.stepperValue.observe(self.stepperValue.observer)
    self.vm.outputs.subTitleLabelHidden.observe(self.subTitleLabelHidden.observer)
    self.vm.outputs.textFieldIsFirstResponder.observe(self.textFieldIsFirstResponder.observer)
    self.vm.outputs.textFieldTextColor.observe(self.textFieldTextColor.observer)
    self.vm.outputs.textFieldValue.observe(self.textFieldValue.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
  }

  func testAmountCurrencyAndStepper_FromBacking() {
    let reward = Reward.postcards
      |> Reward.lens.minimum .~ 6

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    self.vm.inputs.configureWith(data: (project, reward: Reward.postcards, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([0])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(0)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([0])
    self.textFieldValue.assertValues(["0"])
  }

  func testAmountMax_WhenShippingAmountUpdates() {
    self.vm.inputs.configureWith(data: (.template, reward: Reward.postcards, 0))

    self.amountMax.assertValues([10_000])

    self.vm.inputs.unavailableAmountChanged(to: 20)

    self.amountMax.assertValues([10_000, 9_980])
  }

  func testAmountCurrencyAndStepper_FromBacking_DifferentReward() {
    let otherReward = Reward.otherReward
      |> Reward.lens.minimum .~ 60

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
      )

    self.vm.inputs.configureWith(data: (project, reward: otherReward, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([00])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(0)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([0])
    self.textFieldValue.assertValues(["0"])
  }

  func testAmountCurrencyAndStepper_FromBacking_NoReward() {
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ nil
          |> Backing.lens.rewardId .~ nil
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.amount .~ 5.0
      )

    let noReward = Reward.noReward
      |> Reward.lens.minimum .~ 1

    self.vm.inputs.configureWith(data: (project, reward: noReward, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([1])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([1])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(1)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([1])
    self.textFieldValue.assertValues(["1"])
  }

  func testAmountCurrencyAndStepper_NoReward() {
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 1
    self.vm.inputs.configureWith(data: (.template, reward: reward, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([1])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([1])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(1)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([1])
    self.textFieldValue.assertValues(["1"])
  }

  func testAmountCurrencyAndStepper_Currency_Not_Country_HasMinMax_NoReward() {
    let reward = Reward.noReward
      |> Reward.lens.minimum .~ 1
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode

    self.vm.inputs.configureWith(data: (project, reward: reward, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([10])
    self.amountMax.assertValues([200_000])
    self.amountValue.assertValues([10])
    self.currency.assertValues(["MX$"])
    self.stepperMinValue.assertValue(10)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([10])
    self.textFieldValue.assertValues(["10"])
  }

  func testAmountCurrencyAndStepper_Country_DoesNotHaveMinMax_NoReward() {
    let countryWithNilMiniumPledge = Project.Country.us
      |> Project.Country.lens.minPledge .~ nil

    let launchedCountries = LaunchedCountries(countries: [countryWithNilMiniumPledge])

    withEnvironment(launchedCountries: launchedCountries) {
      let country = Project.Country.us
        |> Project.Country.lens.minPledge .~ nil

      let project = Project.template
        |> Project.lens.stats.currency .~ country.currencyCode
        |> Project.lens.country .~ country

      let reward = Reward.noReward
        |> Reward.lens.minimum .~ 1

      self.vm.inputs.configureWith(data: (project, reward: reward, 0))

      self.amountIsValid.assertValues([true])
      self.amountMin.assertValues([1])
      self.amountMax.assertValues([10_000])
      self.amountValue.assertValues([1])
      self.currency.assertValues(["$"])
      self.stepperMinValue.assertValue(1)
      self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
      self.stepperValue.assertValues([1])
      self.textFieldValue.assertValues(["1"])
    }
  }

  func testAmountCurrencyAndStepper_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([0])
    self.currency.assertValues(["$"])
    self.stepperMinValue.assertValue(0)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([0])
    self.textFieldValue.assertValues(["0"])
  }

  func testAmountCurrencyAndStepper_Reward_Minimum_Custom() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.jp.currencyCode

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(data: (project, reward: reward, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([1_200_000])
    self.amountValue.assertValues([0])
    self.currency.assertValues(["¥"])
    self.stepperMinValue.assertValue(0)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([0])
    self.textFieldValue.assertValues(["0"])
  }

  func testDoneButtonIsEnabled_WithMaxAmount_WhenShippingAmountUpdates() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.amountMax.assertValues([10_000])

    self.vm.inputs.textFieldDidEndEditing("10000")

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.unavailableAmountChanged(to: 10)

    self.amountMax.assertValues([10_000, 10_000, 9_990])
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.unavailableAmountChanged(to: 0)

    self.amountMax.assertValues([10_000, 10_000, 9_990, 10_000])
    self.doneButtonIsEnabled.assertValues([true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_NoReward() {
    self.vm.inputs.configureWith(data: (.template, reward: Reward.noReward, 0))

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

  func testDoneButtonIsEnabled_Stepper_ProjectCurrency_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.hk.currencyCode

    self.vm.inputs.configureWith(data: (project, reward: Reward.noReward, 0))

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

  func testDoneButtonIsEnabled_Stepper_ProjectCurrencyCountry_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: Reward.noReward, 0))

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
  }

  func testDoneButtonIsEnabled_Stepper_ProjectCurrencyCountry_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(10_001)
    self.doneButtonIsEnabled.assertValues([true, false, true, false])

    self.vm.inputs.stepperValueChanged(0)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_ProjectCurrencyCountry_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(data: (.template, reward: reward, 0))

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(300)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(100)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, false, true])
  }

  func testDoneButtonIsEnabled_Stepper_ProjectCountryCurrency_DoesNotHaveMinMax_Reward_Minimum_Template() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: .template, 0))

      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.stepperValueChanged(11)
      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.stepperValueChanged(100_000)
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.stepperValueChanged(10_000)
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.stepperValueChanged(0)
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.stepperValueChanged(10)
      self.doneButtonIsEnabled.assertValues([true, false, true])
    }
  }

  func testDoneButtonIsEnabled_Stepper_ProjectCountryCurrency_DoesNotHaveMinMax_Reward_Minimum_Custom() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: reward, 0))

      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.stepperValueChanged(300)
      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.stepperValueChanged(100_000)
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.stepperValueChanged(10_000)
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.stepperValueChanged(0)
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.stepperValueChanged(200)
      self.doneButtonIsEnabled.assertValues([true, false, true])
    }
  }

  func testDoneButtonIsEnabled_TextField_NoReward() {
    self.vm.inputs.configureWith(data: (.template, reward: Reward.noReward, 0))

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

  func testDoneButtonIsEnabled_TextField_ProjectCountryCurrency_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.hk.currencyCode

    self.vm.inputs.configureWith(data: (project, reward: Reward.noReward, 0))

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

  func testDoneButtonIsEnabled_TextField_ProjectCurrencyCountry_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: Reward.noReward, 0))

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
  }

  func testDoneButtonIsEnabled_TextField_ProjectCurrencyCountry_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("11")
    self.doneButtonIsEnabled.assertValues([true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_ProjectCurrencyCountry_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(data: (.template, reward: reward, 0))

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("100")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, false, true])
  }

  func testDoneButtonIsEnabled_TextField_ProjectCurrencyCountry_DoesNotHaveMinMax_Reward_Minimum_Template() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: .template, 0))

      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.textFieldValueChanged("11")
      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.textFieldValueChanged("100000")
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.textFieldValueChanged("10000")
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.textFieldValueChanged("0")
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.textFieldValueChanged("10")
      self.doneButtonIsEnabled.assertValues([true, false, true])
    }
  }

  func testDoneButtonIsEnabled_TextField_ProjectCurrencyCountry_DoesNotHaveMinMax_Reward_Minimum_Custom() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: reward, 0))

      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.textFieldValueChanged("300")
      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.textFieldValueChanged("100000")
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.textFieldValueChanged("10000")
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.textFieldValueChanged("0")
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.textFieldValueChanged("200")
      self.doneButtonIsEnabled.assertValues([true, false, true])
    }
  }

  func testDoneButtonIsEnabled_Combined_NoReward() {
    self.vm.inputs.configureWith(data: (.template, reward: Reward.noReward, 0))

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

  func testDoneButtonIsEnabled_Combined_ProjectCountryCurrency_HasMinMax_NoReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.hk.currencyCode

    self.vm.inputs.configureWith(data: (project, reward: Reward.noReward, 0))

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

  func testDoneButtonIsEnabled_Combined_ProjectCurrencyCountry_DoesNotHaveMinMax_NoReward() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: Reward.noReward, 0))

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
  }

  func testDoneButtonIsEnabled_Combined_ProjectCurrencyCountry_HasMinMax_Reward_Minimum_Template() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("100000")
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("0")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(11)
    self.doneButtonIsEnabled.assertValues([true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_ProjectCurrencyCountry_HasMinMax_Reward_Minimum_Custom() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(data: (.template, reward: reward, 0))

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("300")
    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(100_000)
    self.doneButtonIsEnabled.assertValues([true, false])

    self.vm.inputs.textFieldValueChanged("10000")
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.stepperValueChanged(100)
    self.doneButtonIsEnabled.assertValues([true, false, true])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, false, true])
  }

  func testDoneButtonIsEnabled_Combined_ProjectCurrencyCountry_DoesNotHaveMinMax_Reward_Minimum_Template() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: .template, 0))

      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.stepperValueChanged(11)
      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.textFieldValueChanged("100000")
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.stepperValueChanged(10_000)
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.textFieldValueChanged("0")
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.stepperValueChanged(10)
      self.doneButtonIsEnabled.assertValues([true, false, true])
    }
  }

  func testDoneButtonIsEnabled_Combined_ProjectCurrencyCountry_DoesNotHaveMinMax_Reward_Minimum_Custom() {
    let country = Project.Country.au
      |> Project.Country.lens.minPledge .~ nil
      |> Project.Country.lens.maxPledge .~ nil

    let project = Project.template
      |> Project.lens.stats.currency .~ country.currencyCode

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    let launchedCountries = LaunchedCountries(countries: [country])

    withEnvironment(launchedCountries: launchedCountries) {
      self.vm.inputs.configureWith(data: (project, reward: reward, 0))

      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.textFieldValueChanged("300")
      self.doneButtonIsEnabled.assertValues([true])

      self.vm.inputs.stepperValueChanged(100_000)
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.stepperValueChanged(10_001)
      self.doneButtonIsEnabled.assertValues([true, false])

      self.vm.inputs.stepperValueChanged(0)
      self.doneButtonIsEnabled.assertValues([true, false, true])

      self.vm.inputs.textFieldValueChanged("200")
      self.doneButtonIsEnabled.assertValues([true, false, true])
    }
  }

  func testGenerateSelectionFeedback() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))
    self.generateSelectionFeedback.assertDidNotEmitValue()

    self.vm.inputs.stepperValueChanged(11)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(PledgeAmountStepperConstants.max)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(12)
    self.generateSelectionFeedback.assertValueCount(3)

    self.vm.inputs.stepperValueChanged(0)
    self.generateSelectionFeedback.assertValueCount(4)

    self.vm.inputs.stepperValueChanged(20)
    self.generateSelectionFeedback.assertValueCount(5)
  }

  // FIXME: Not sure why this notification is triggered when stepper value is inside the min/max bounds.
  func testGenerateNotificationWarningFeedback() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))
    self.generateNotificationWarningFeedback.assertDidNotEmitValue()

    self.vm.inputs.stepperValueChanged(11)
    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(PledgeAmountStepperConstants.max)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(12)
    self.generateNotificationWarningFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(0)
    self.generateNotificationWarningFeedback.assertValueCount(3)

    self.vm.inputs.stepperValueChanged(11)
    self.generateNotificationWarningFeedback.assertValueCount(4)
  }

  func testLabelTextColor() {
    let green = UIColor.ksr_create_700
    let red = UIColor.ksr_alert

    self.vm.inputs.configureWith(data: (.template, reward: Reward.noReward, 0))

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

  func testLabelTextColor_WhenShippingAmountUpdates() {
    let green = UIColor.ksr_create_700
    let red = UIColor.ksr_alert

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.labelTextColor.assertValues([green])

    self.vm.inputs.stepperValueChanged(10_000)
    self.labelTextColor.assertValues([green])

    self.vm.inputs.unavailableAmountChanged(to: 30)
    self.labelTextColor.assertValues([green, red])

    self.vm.inputs.stepperValueChanged(9_970)
    self.labelTextColor.assertValues([green, red, green])
  }

  func testMaxPledgeAmountErrorLabelIsHidden() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25

    self.vm.inputs.configureWith(data: (project, reward: reward, 0))
    self.maxPledgeAmountErrorLabelIsHidden.assertValues([true])

    self.vm.inputs.stepperValueChanged(10_500)
    self.maxPledgeAmountErrorLabelIsHidden.assertValues([true, false])

    self.vm.inputs.stepperValueChanged(10_000)
    self.maxPledgeAmountErrorLabelIsHidden.assertValues([true, false, true])

    let shippingAmount = 30.0
    self.vm.inputs.unavailableAmountChanged(to: shippingAmount)
    self.maxPledgeAmountErrorLabelIsHidden.assertValues([true, false, true, false])
  }

  func testMaxPledgeAmountErrorLabelText_WithUS_CountryCurrency_Success() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25

    self.vm.inputs.configureWith(data: (project, reward: reward, 0))
    self.vm.inputs.stepperValueChanged(10_100)

    self.maxPledgeAmountErrorLabelText.assertValues([
      "Enter an amount less than US$ 10,000."
    ])

    self.vm.inputs.unavailableAmountChanged(to: 30.0)

    self.maxPledgeAmountErrorLabelText.assertValues([
      "Enter an amount less than US$ 10,000.",
      "Enter an amount less than US$ 9,970."
    ])
  }

  func testMaxPledgeAmountErrorLabelText_WithNonUS_CountryCurrency_Success() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
    let reward = Reward.template
      |> Reward.lens.minimum .~ 25

    self.vm.inputs.configureWith(data: (project, reward: reward, 0))
    self.vm.inputs.stepperValueChanged(200_100)

    self.maxPledgeAmountErrorLabelText.assertValues([
      "Enter an amount less than MX$ 200,000."
    ])

    self.vm.inputs.unavailableAmountChanged(to: 30.0)

    self.maxPledgeAmountErrorLabelText.assertValues([
      "Enter an amount less than MX$ 200,000.",
      "Enter an amount less than MX$ 199,970."
    ])
  }

  func testStepperValueChangesWithTextFieldInput() {
    let maxValue = PledgeAmountStepperConstants.max

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))
    self.stepperValue.assertValues([0])

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([0, 11])

    self.vm.inputs.textFieldValueChanged("16")
    self.stepperValue.assertValues([0, 11, 16])

    self.vm.inputs.textFieldValueChanged(String(format: "%.0f", maxValue))
    self.stepperValue.assertValues([0, 11, 16, maxValue])

    self.vm.inputs.textFieldValueChanged("0")
    self.stepperValue.assertValues([0, 11, 16, maxValue, 0])

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([0, 11, 16, maxValue, 0, 11])
  }

  func testTextFieldIsFirstResponder() {
    self.vm.inputs.doneButtonTapped()

    self.textFieldIsFirstResponder.assertValue(false)
  }

  func testNilInputReturnsZero() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValue(0)

    self.vm.inputs.textFieldValueChanged("11")
    self.amountIsValid.assertValues([true, true])
    self.amountMin.assertValues([0, 0])
    self.amountMax.assertValues([10_000, 10_000])
    self.amountValue.assertValues([0, 11])

    self.vm.inputs.textFieldValueChanged("")
    self.amountIsValid.assertValues([true, true, true])
    self.amountMin.assertValues([0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 11, 0])

    self.vm.inputs.textFieldValueChanged("5")
    self.amountIsValid.assertValues([true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 11, 0, 5])

    self.vm.inputs.textFieldValueChanged(nil)
    self.amountIsValid.assertValues([true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 11, 0, 5, 0])
  }

  func testTextFieldDidEndEditing() {
    let maxValue = PledgeAmountStepperConstants.max
    let maxValueFormatted = String(format: "%.0f", maxValue)

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))
    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([0])
    self.textFieldValue.assertValues(["0"])

    self.vm.inputs.textFieldDidEndEditing(nil)
    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([0])
    self.textFieldValue.assertValues(["0"])

    self.vm.inputs.textFieldDidEndEditing("16")
    self.amountIsValid.assertValues([true, true])
    self.amountMin.assertValues([0, 0])
    self.amountMax.assertValues([10_000, 10_000])
    self.amountValue.assertValues([0, 16])
    self.textFieldValue.assertValues(["0", "16"])

    self.vm.inputs.textFieldDidEndEditing(String(maxValue))
    self.amountIsValid.assertValues([true, true, false])
    self.amountMin.assertValues([0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 16, maxValue])
    self.textFieldValue.assertValues(["0", "16", maxValueFormatted])

    self.vm.inputs.textFieldDidEndEditing("0")
    self.amountIsValid.assertValues([true, true, false, true])
    self.amountMin.assertValues([0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 16, maxValue, 0])
    self.textFieldValue.assertValues(["0", "16", maxValueFormatted, "0"])

    self.vm.inputs.textFieldDidEndEditing("17")
    self.amountIsValid.assertValues([true, true, false, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 16, maxValue, 0, 17])
    self.textFieldValue.assertValues(["0", "16", maxValueFormatted, "0", "17"])

    self.vm.inputs.textFieldDidEndEditing("")
    self.amountIsValid.assertValues([true, true, false, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 16, maxValue, 0, 17])
    self.textFieldValue.assertValues(["0", "16", maxValueFormatted, "0", "17"])
  }

  func testTextFieldTextColor() {
    let green = UIColor.ksr_create_700
    let red = UIColor.ksr_alert

    self.vm.inputs.configureWith(data: (.template, reward: Reward.noReward, 0))

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

  func testTextFieldValueChangedRounding() {
    let green = UIColor.ksr_create_700
    let red = UIColor.ksr_alert

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([10_000])
    self.amountValue.assertValues([0])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10")
    self.amountIsValid.assertValues([true, true])
    self.amountMin.assertValues([0, 0])
    self.amountMax.assertValues([10_000, 10_000])
    self.amountValue.assertValues([0, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.")
    self.amountIsValid.assertValues([true, true, true])
    self.amountMin.assertValues([0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.0")
    self.amountIsValid.assertValues([true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.00")
    self.amountIsValid.assertValues([true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.01")
    self.amountIsValid.assertValues([true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.010")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.0100")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01, 10.01])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.019")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0, 0, 0])
    self.amountMax.assertValues([10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01, 10.02])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("10.0194444444")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    self.amountMax
      .assertValues([10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01, 10.02])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("9.999")
    self.amountIsValid.assertValues([true, true, true, true, true, true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    self.amountMax
      .assertValues([10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02, 10])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01, 10.02, 10])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("9.99")
    self.amountIsValid
      .assertValues([true, true, true, true, true, true, true, true, true, true, true, true])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    self.amountMax
      .assertValues([
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000
      ])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02, 10, 9.99])
    self.doneButtonIsEnabled.assertValues([true])
    self.labelTextColor.assertValues([green])
    self.stepperValue.assertValues([0, 10, 10.01, 10.02, 10, 9.99])
    self.textFieldTextColor.assertValues([green])

    self.vm.inputs.textFieldValueChanged("-1.00")
    self.amountIsValid
      .assertValues([true, true, true, true, true, true, true, true, true, true, true, true, false])
    self.amountMin.assertValues([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    self.amountMax
      .assertValues([
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000,
        10_000
      ])
    self.amountValue.assertValues([0, 10, 10, 10, 10, 10.01, 10.01, 10.01, 10.02, 10.02, 10, 9.99, -1.0])
    self.doneButtonIsEnabled.assertValues([true, false])
    self.labelTextColor.assertValues([green, red])
    self.stepperValue.assertValues([0, 10, 10.01, 10.02, 10, 9.99, -1.0])
    self.textFieldTextColor.assertValues([green, red])
  }

  func testTextFieldDidEndEditingRoundingAndTruncation() {
    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.textFieldValue.assertValues(["0"])

    self.vm.inputs.textFieldDidEndEditing("10.")
    self.textFieldValue.assertValues(["0", "10"])

    self.vm.inputs.textFieldDidEndEditing("10.0")
    self.textFieldValue.assertValues(["0", "10", "10"])

    self.vm.inputs.textFieldDidEndEditing("10.00")
    self.textFieldValue.assertValues(["0", "10", "10", "10"])

    self.vm.inputs.textFieldDidEndEditing("10.01")
    self.textFieldValue.assertValues(["0", "10", "10", "10", "10.01"])

    self.vm.inputs.textFieldDidEndEditing("10.010")
    self.textFieldValue.assertValues(["0", "10", "10", "10", "10.01", "10.01"])

    self.vm.inputs.textFieldDidEndEditing("10.0100")
    self.textFieldValue.assertValues(["0", "10", "10", "10", "10.01", "10.01", "10.01"])

    self.vm.inputs.textFieldDidEndEditing("10.019")
    self.textFieldValue.assertValues(["0", "10", "10", "10", "10.01", "10.01", "10.01", "10.02"])

    self.vm.inputs.textFieldDidEndEditing("10.0194444444")
    self.textFieldValue.assertValues(["0", "10", "10", "10", "10.01", "10.01", "10.01", "10.02", "10.02"])

    self.vm.inputs.textFieldDidEndEditing("9.999")
    self.textFieldValue
      .assertValues(["0", "10", "10", "10", "10.01", "10.01", "10.01", "10.02", "10.02", "10"])

    self.vm.inputs.textFieldDidEndEditing("9.99")
    self.textFieldValue
      .assertValues(["0", "10", "10", "10", "10.01", "10.01", "10.01", "10.02", "10.02", "10", "9.99"])
  }

  func testPlusSignLabelHidden_NoReward() {
    self.plusSignLabelHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (.template, reward: .noReward, 0))

    self.plusSignLabelHidden.assertValues([true])
  }

  func testPlusSignLabelHidden_RegularReward() {
    self.plusSignLabelHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.plusSignLabelHidden.assertValues([false])
  }

  func testSubtitleLabelHidden_NoReward() {
    self.subTitleLabelHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (.template, reward: .noReward, 0))

    self.subTitleLabelHidden.assertValues([true])
  }

  func testSubtitleLabelHidden_RegularReward() {
    self.plusSignLabelHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.plusSignLabelHidden.assertValues([false])
  }

  func testTitleLabelText_NoReward() {
    self.titleLabelText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (.template, reward: .noReward, 0))

    self.titleLabelText.assertValues(["Your pledge amount"])
  }

  func testTitleLabelText_RegularReward() {
    self.titleLabelText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (.template, reward: .template, 0))

    self.titleLabelText.assertValues(["Bonus support"])
  }

  func testCurrentAmount_BackedReward_EditingSameReward() {
    let reward = Reward.template

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.status .~ .pledged
      )

    self.amountIsValid.assertDidNotEmitValue()
    self.amountMin.assertDidNotEmitValue()
    self.amountMax.assertDidNotEmitValue()
    self.amountValue.assertDidNotEmitValue()
    self.currency.assertDidNotEmitValue()
    self.stepperMinValue.assertDidNotEmitValue()
    self.stepperMaxValue.assertDidNotEmitValue()
    self.stepperValue.assertDidNotEmitValue()
    self.textFieldValue.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (project, reward: reward, 50))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([8_000])
    self.amountValue.assertValues([50])
    self.currency.assertValues(["£"])
    self.stepperMinValue.assertValue(0)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([50.0])
    self.textFieldValue.assertValues(["50"])
  }

  func testCurrentAmount_BackedReward_EditingDifferentReward() {
    let reward = Reward.template
    let otherReward = Reward.template
      |> Reward.lens.id .~ 5

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.status .~ .pledged
      )

    self.amountIsValid.assertDidNotEmitValue()
    self.amountMin.assertDidNotEmitValue()
    self.amountMax.assertDidNotEmitValue()
    self.amountValue.assertDidNotEmitValue()
    self.currency.assertDidNotEmitValue()
    self.stepperMinValue.assertDidNotEmitValue()
    self.stepperMaxValue.assertDidNotEmitValue()
    self.stepperValue.assertDidNotEmitValue()
    self.textFieldValue.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data: (project, reward: otherReward, 50))

    self.amountIsValid.assertValues([true])
    self.amountMin.assertValues([0])
    self.amountMax.assertValues([8_000])
    self.amountValue.assertValues([50])
    self.currency.assertValues(["£"])
    self.stepperMinValue.assertValue(0)
    self.stepperMaxValue.assertValue(PledgeAmountStepperConstants.max)
    self.stepperValue.assertValues([50.0])
    self.textFieldValue.assertValues(["50"])
  }
}
