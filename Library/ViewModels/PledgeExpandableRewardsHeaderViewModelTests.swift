@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeExpandableRewardsHeaderViewModelTests: TestCase {
  internal let vm: PledgeExpandableRewardsHeaderViewModelType = PledgeExpandableRewardsHeaderViewModel()

  private let loadRewardsIntoDataSource = TestObserver<[PledgeExpandableRewardsHeaderItem], Never>()
  private let expandRewards = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadRewardsIntoDataSource.observe(self.loadRewardsIntoDataSource.observer)
    self.vm.outputs.expandRewards.observe(self.expandRewards.observer)
  }

  func testLoadRewardsIntoDataSource() {
    self.loadRewardsIntoDataSource.assertDidNotEmitValue()

    let reward1 = Reward.template
      |> Reward.lens.id .~ Int(1)
      |> Reward.lens.title .~ "Reward 1"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_361_315
      |> Reward.lens.minimum .~ 60

    let reward2 = Reward.template
      |> Reward.lens.id .~ Int(2)
      |> Reward.lens.title .~ "Reward 2"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_461_315
      |> Reward.lens.minimum .~ 20

    let reward3 = Reward.template
      |> Reward.lens.id .~ Int(3)
      |> Reward.lens.title .~ "Reward 3"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_561_315
      |> Reward.lens.minimum .~ 40

    let data = PledgeExpandableRewardsHeaderViewData(
      rewards: [reward1, reward2, reward3],
      selectedQuantities: [reward1.id: 1, reward2.id: 1, reward3.id: 2],
      projectCountry: .us,
      omitCurrencyCode: false
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.loadRewardsIntoDataSource.assertValueCount(1)

    guard let itemData = self.loadRewardsIntoDataSource.lastValue else {
      XCTFail("Should have data")
      return
    }

    XCTAssertEqual(itemData.count, 4)

    XCTAssertEqual(itemData[0].data.text, "Estimated delivery October 2016")
    XCTAssertEqual(itemData[0].data.amount.string, " US$ 160")
    XCTAssertEqual(itemData[0].isHeader, true)
    XCTAssertEqual(itemData[0].isReward, false)

    XCTAssertEqual(itemData[1].data.text, "Reward 1")
    XCTAssertEqual(itemData[1].data.amount.string, "US$ 60")
    XCTAssertEqual(itemData[1].isHeader, false)
    XCTAssertEqual(itemData[1].isReward, true)

    XCTAssertEqual(itemData[2].data.text, "Reward 2")
    XCTAssertEqual(itemData[2].data.amount.string, "US$ 20")
    XCTAssertEqual(itemData[2].isHeader, false)
    XCTAssertEqual(itemData[2].isReward, true)

    XCTAssertEqual(itemData[3].data.text, "2 x Reward 3")
    XCTAssertEqual(itemData[3].data.amount.string, "US$ 40")
    XCTAssertEqual(itemData[3].isHeader, false)
    XCTAssertEqual(itemData[3].isReward, true)
  }

  func testExpandRewards() {
    self.expandRewards.assertDidNotEmitValue()

    let data = PledgeExpandableRewardsHeaderViewData(
      rewards: [.template, .template, .template],
      selectedQuantities: [:],
      projectCountry: .us,
      omitCurrencyCode: false
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    self.expandRewards.assertDidNotEmitValue()

    self.vm.inputs.expandButtonTapped()

    self.expandRewards.assertValues([true])

    self.vm.inputs.expandButtonTapped()

    self.expandRewards.assertValues([true, false])

    self.vm.inputs.expandButtonTapped()

    self.expandRewards.assertValues([true, false, true])
  }
}
