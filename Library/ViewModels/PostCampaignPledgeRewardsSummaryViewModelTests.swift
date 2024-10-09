@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PostCampaignPledgeRewardsSummaryViewModelTests: TestCase {
  internal let vm: PostCampaignPledgeRewardsSummaryViewModelType =
    PostCampaignPledgeRewardsSummaryViewModel()

  private let loadRewardsIntoDataSource = TestObserver<[PostCampaignRewardsSummaryItem], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadRewardsIntoDataSource.observe(self.loadRewardsIntoDataSource.observer)
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

    let bonus = 10.0
    let total: Double = 60.0 + 2 * 20.0 + 3 * 40.0 + bonus

    let rewardsData = PostCampaignRewardsSummaryViewData(
      rewards: [reward1, reward2, reward3],
      selectedQuantities: [reward1.id: 1, reward2.id: 2, reward3.id: 3],
      projectCountry: .us,
      omitCurrencyCode: false,
      shipping: nil
    )

    let pledgeData = PledgeSummaryViewData(
      project: Project.template,
      total: total,
      confirmationLabelHidden: true,
      pledgeHasNoReward: false
    )

    self.vm.inputs.configureWith(
      rewardsData: rewardsData,
      bonusAmount: bonus,
      pledgeData: pledgeData
    )

    self.vm.inputs.viewDidLoad()

    self.loadRewardsIntoDataSource.assertValueCount(1)

    guard let itemData = self.loadRewardsIntoDataSource.lastValue else {
      XCTFail("Should have data")
      return
    }

    XCTAssertEqual(itemData.count, 5)

    XCTAssertEqual(itemData[0].data.text, "Estimated delivery October 2016")
    XCTAssertEqual(itemData[0].data.amount.string, "")
    XCTAssertEqual(itemData[0].isHeader, true)
    XCTAssertEqual(itemData[0].isReward, false)

    XCTAssertEqual(itemData[1].data.text, "Reward 1")
    XCTAssertEqual(itemData[1].data.amount.string, "US$ 60")
    XCTAssertEqual(itemData[1].isHeader, false)
    XCTAssertEqual(itemData[1].isReward, true)

    XCTAssertEqual(itemData[2].data.text, "2 x Reward 2")
    XCTAssertEqual(itemData[2].data.amount.string, "US$ 40")
    XCTAssertEqual(itemData[2].isHeader, false)
    XCTAssertEqual(itemData[2].isReward, true)

    XCTAssertEqual(itemData[3].data.text, "3 x Reward 3")
    XCTAssertEqual(itemData[3].data.amount.string, "US$ 120")
    XCTAssertEqual(itemData[3].isHeader, false)
    XCTAssertEqual(itemData[3].isReward, true)

    XCTAssertEqual(itemData[4].data.text, "Bonus support")
    XCTAssertEqual(itemData[4].data.amount.string, "US$ 10")
    XCTAssertEqual(itemData[4].isHeader, false)
    XCTAssertEqual(itemData[4].isReward, true)
  }
}
