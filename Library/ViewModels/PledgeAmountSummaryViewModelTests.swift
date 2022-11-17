import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeAmountSummaryViewModelTests: TestCase {
  private let vm: PledgeAmountSummaryViewModelType = PledgeAmountSummaryViewModel()

  private let bonusAmountText = TestObserver<String, Never>()
  private let bonusAmountStackViewIsHidden = TestObserver<Bool, Never>()
  private let pledgeAmountText = TestObserver<String, Never>()
  private let shippingAmountText = TestObserver<String, Never>()
  private let shippingLocationStackViewIsHidden = TestObserver<Bool, Never>()
  private let shippingLocationText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.bonusAmountText.map { $0.string }
      .observe(self.bonusAmountText.observer)
    self.vm.outputs.bonusAmountStackViewIsHidden
      .observe(self.bonusAmountStackViewIsHidden.observer)
    self.vm.outputs.pledgeAmountText.map { $0.string }
      .observe(self.pledgeAmountText.observer)
    self.vm.outputs.shippingAmountText.map { $0.string }
      .observe(self.shippingAmountText.observer)
    self.vm.outputs.shippingLocationStackViewIsHidden
      .observe(self.shippingLocationStackViewIsHidden.observer)
    self.vm.outputs.shippingLocationText.observe(self.shippingLocationText.observer)
  }

  func testTextOutputsEmitTheCorrectValue_US_ProjectCountryCode() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 5,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "United States",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 23,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.bonusAmountText.assertValue("+$5.00")
    self.pledgeAmountText.assertValue("$23.00")
    self.shippingAmountText.assertValue("+$7.00")
    self.shippingLocationText.assertValue("Shipping: United States")
  }

  func testTextOutputsEmitTheCorrectValue_NonUS_ProjectCountryCode() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 5,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "Mexico",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.mx,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 23,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.bonusAmountText.assertValue("+ MX$ 5.00")
    self.pledgeAmountText.assertValue(" MX$ 23.00")
    self.shippingAmountText.assertValue("+ MX$ 7.00")
    self.shippingLocationText.assertValue("Shipping: Mexico")
  }

  func testTextOutputsEmitTheCorrectValue_ZeroShippingAmount() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "United States",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountText.assertValue("$30.00")
    self.shippingAmountText.assertValue("+$0.00")
    self.shippingLocationText.assertValue("Shipping: United States")
  }

  func testShippingLocationStackViewIsHidden_isTrue_WhenLocationNameIsNil() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: nil,
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }

  func testShippingLocationStackViewIsHidden_isTrue_WhenShippingAmountIsHidden() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "United States",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 7.0,
      shippingAmountHidden: true,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }

  func testShippingLocationStackViewIsHidden_isFalse_WhenLocationNameIsNotNil() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "United States",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(false)
  }

  func testShippingLocationStackViewIsHidden_isTrue_WhenRewardIsLocalPickup() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "United States",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: true
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }

  func testShippingLocationStackViewIsHidden_isFalse_WhenRewardIsNotLocalPickup() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: "United States",
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(false)
  }

  func testBonusAmountStackViewIsHidden_isTrue_WhenIsNoReward() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 1,
      bonusAmountHidden: false,
      isNoReward: true,
      locationName: nil,
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 0,
      shippingAmount: 0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.bonusAmountStackViewIsHidden.assertValue(true)
  }

  func testBonusAmountStackViewIsHidden_isFalse_WhenIsNotNoReward() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 0,
      bonusAmountHidden: false,
      isNoReward: false,
      locationName: nil,
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 30,
      shippingAmount: 7.0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.bonusAmountStackViewIsHidden.assertValue(false)
  }

  func testBonusAmountStackViewIsHidden_isTrue_WhenBonusAmountHidden() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 1,
      bonusAmountHidden: true,
      isNoReward: true,
      locationName: nil,
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 0,
      shippingAmount: 0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.bonusAmountStackViewIsHidden.assertValue(true)
  }

  func testPledgeAmountText_NoReward_NonUS_ProjectCurrencyCode() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 2,
      bonusAmountHidden: false,
      isNoReward: true,
      locationName: nil,
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.es,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 0,
      shippingAmount: 0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountText.assertValues(["€2.00"], "Bonus amount is used as pledge total for No Reward type")
  }

  func testPledgeAmountText_NoReward_US_ProjectCurrencyCode() {
    let data = PledgeAmountSummaryViewData(
      bonusAmount: 2,
      bonusAmountHidden: false,
      isNoReward: true,
      locationName: nil,
      omitUSCurrencyCode: true,
      projectCurrencyCountry: Project.Country.us,
      pledgedOn: 1_568_666_243.0,
      rewardMinimum: 0,
      shippingAmount: 0,
      shippingAmountHidden: false,
      rewardIsLocalPickup: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountText.assertValues(["$2.00"], "Bonus amount is used as pledge total for No Reward type")
  }
}
