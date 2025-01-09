@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PostCampaignPledgeRewardsSummaryViewModelTests: TestCase {
  internal let vm: PostCampaignPledgeRewardsSummaryViewModelType =
    PostCampaignPledgeRewardsSummaryViewModel()

  private let loadRewardsIntoDataSource = TestObserver<
    (headerData: PledgeSummaryRewardCellData?, rewards: [PledgeSummaryRewardCellData]),
    Never
  >()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadRewardsIntoDataSource.observe(self.loadRewardsIntoDataSource.observer)
  }

  func testLoadRewardsIntoDataSource_latePledge() {
    self.loadRewardsIntoDataSource.assertDidNotEmitValue()

    let (rewardsData, bonus, pledgeData) = self.getTestData(useLatePledgeCosts: true)

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

    let headerItemData = itemData.headerData
    let rewardItemData = itemData.rewards

    XCTAssertNotNil(headerItemData)
    XCTAssertEqual(rewardItemData.count, 4)

    XCTAssertEqual(headerItemData?.text, "Estimated delivery October 2016")
    XCTAssertEqual(headerItemData?.amount.string, "")

    XCTAssertEqual(rewardItemData[0].text, "Reward 1")
    XCTAssertEqual(rewardItemData[0].amount.string, "US$ 63")
    XCTAssertEqual(rewardItemData[0].showHeader, false)
    XCTAssertNil(rewardItemData[0].headerText)

    XCTAssertEqual(rewardItemData[1].text, "2 x Reward 2")
    XCTAssertEqual(rewardItemData[1].amount.string, "US$ 46")
    XCTAssertEqual(rewardItemData[1].showHeader, false)
    XCTAssertNil(rewardItemData[1].headerText)

    XCTAssertEqual(rewardItemData[2].text, "3 x Reward 3")
    XCTAssertEqual(rewardItemData[2].amount.string, "US$ 129")
    XCTAssertEqual(rewardItemData[2].showHeader, false)
    XCTAssertNil(rewardItemData[2].headerText)

    XCTAssertEqual(rewardItemData[3].text, "Bonus support")
    XCTAssertEqual(rewardItemData[3].amount.string, "US$ 10")
    XCTAssertEqual(rewardItemData[3].showHeader, false)
    XCTAssertNil(rewardItemData[3].headerText)
  }

  func testLoadRewardsIntoDataSource_crowdfundingPledge() {
    self.loadRewardsIntoDataSource.assertDidNotEmitValue()

    let (rewardsData, bonus, pledgeData) = self.getTestData(useLatePledgeCosts: false)

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

    let headerItemData = itemData.headerData
    let rewardItemData = itemData.rewards

    XCTAssertNotNil(headerItemData)
    XCTAssertEqual(rewardItemData.count, 4)

    XCTAssertEqual(headerItemData?.text, "Estimated delivery October 2016")
    XCTAssertEqual(headerItemData?.amount.string, "")

    XCTAssertEqual(rewardItemData[0].text, "Reward 1")
    XCTAssertEqual(rewardItemData[0].amount.string, "US$ 62")
    XCTAssertEqual(rewardItemData[0].showHeader, false)
    XCTAssertNil(rewardItemData[0].headerText)

    XCTAssertEqual(rewardItemData[1].text, "2 x Reward 2")
    XCTAssertEqual(rewardItemData[1].amount.string, "US$ 44")
    XCTAssertEqual(rewardItemData[1].showHeader, false)
    XCTAssertNil(rewardItemData[1].headerText)

    XCTAssertEqual(rewardItemData[2].text, "3 x Reward 3")
    XCTAssertEqual(rewardItemData[2].amount.string, "US$ 126")
    XCTAssertEqual(rewardItemData[2].showHeader, false)
    XCTAssertNil(rewardItemData[2].headerText)

    XCTAssertEqual(rewardItemData[3].text, "Bonus support")
    XCTAssertEqual(rewardItemData[3].amount.string, "US$ 10")
    XCTAssertEqual(rewardItemData[3].showHeader, false)
    XCTAssertNil(rewardItemData[3].headerText)
  }

  // MARK: Helpers

  func getTestData(useLatePledgeCosts: Bool)
    -> (PostCampaignRewardsSummaryViewData, Double, PledgeSummaryViewData) {
    let reward1 = Reward.template
      |> Reward.lens.id .~ Int(1)
      |> Reward.lens.title .~ "Reward 1"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_361_315
      |> Reward.lens.minimum .~ 61
      |> Reward.lens.pledgeAmount .~ 62
      |> Reward.lens.latePledgeAmount .~ 63

    let reward2 = Reward.template
      |> Reward.lens.id .~ Int(2)
      |> Reward.lens.title .~ "Reward 2"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_461_315
      |> Reward.lens.minimum .~ 21
      |> Reward.lens.pledgeAmount .~ 22
      |> Reward.lens.latePledgeAmount .~ 23

    let reward3 = Reward.template
      |> Reward.lens.id .~ Int(3)
      |> Reward.lens.title .~ "Reward 3"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_561_315
      |> Reward.lens.minimum .~ 41
      |> Reward.lens.pledgeAmount .~ 42
      |> Reward.lens.latePledgeAmount .~ 43

    let bonus = 10.0
    let total = useLatePledgeCosts
      ? 63.0 + 2 * 23.0 + 3 * 43.0 + bonus
      : 62.0 + 2 * 22.0 + 3 * 42.0 + bonus

    let rewardsData = PostCampaignRewardsSummaryViewData(
      rewards: [reward1, reward2, reward3],
      selectedQuantities: [reward1.id: 1, reward2.id: 2, reward3.id: 3],
      projectCountry: .us,
      omitCurrencyCode: false,
      shipping: nil,
      useLatePledgeCosts: useLatePledgeCosts
    )

    let pledgeData = PledgeSummaryViewData(
      project: Project.template,
      total: total,
      confirmationLabelHidden: true,
      pledgeHasNoReward: false
    )

    return (rewardsData, bonus, pledgeData)
  }
}
