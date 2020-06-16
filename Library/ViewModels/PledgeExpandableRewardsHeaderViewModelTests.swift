@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeExpandableRewardsHeaderViewModelTests: TestCase {
  internal let vm: PledgeExpandableRewardsHeaderViewModelType = PledgeExpandableRewardsHeaderViewModel()

  private let loadRewardsIntoDataSource = TestObserver<[PledgeExpandableRewardsHeaderItem], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadRewardsIntoDataSource.observe(self.loadRewardsIntoDataSource.observer)
  }

  func testLoadRewardsIntoDataSource() {
    self.loadRewardsIntoDataSource.assertDidNotEmitValue()

    let reward1 = Reward.template
      |> Reward.lens.title .~ "Reward 1"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_361_315
      |> Reward.lens.minimum .~ 60

    let reward2 = Reward.template
      |> Reward.lens.title .~ "Reward 2"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_461_315
      |> Reward.lens.minimum .~ 20

    let reward3 = Reward.template
      |> Reward.lens.title .~ "Reward 3"
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_561_315
      |> Reward.lens.minimum .~ 40

    let data: PledgeExpandableRewardsHeaderViewData = (
      [reward1, reward2, reward3],
      .us,
      false
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
    XCTAssertEqual(itemData[0].data.amount.string, " US$ 120")
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

    XCTAssertEqual(itemData[3].data.text, "Reward 3")
    XCTAssertEqual(itemData[3].data.amount.string, "US$ 40")
    XCTAssertEqual(itemData[3].isHeader, false)
    XCTAssertEqual(itemData[3].isReward, true)
  }
}
