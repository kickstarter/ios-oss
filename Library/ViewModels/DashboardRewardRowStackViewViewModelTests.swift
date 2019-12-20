@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class DashboardRewardRowStackViewViewModelTests: TestCase {
  let vm: DashboardRewardRowStackViewViewModelType = DashboardRewardRowStackViewViewModel()

  let backersText = TestObserver<String, Never>()
  let pledgedText = TestObserver<String, Never>()
  let topRewardText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backersText.observe(self.backersText.observer)
    self.vm.outputs.pledgedText.observe(self.pledgedText.observer)
    self.vm.outputs.topRewardText.observe(self.topRewardText.observer)
  }

  func testRewardBackers() {
    let reward = .template
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 50
      |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 5.0
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 250

    self.vm.inputs.configureWith(country: .us, reward: reward, totalPledged: 1_000)

    self.backersText.assertValues(["50"])
    self.pledgedText.assertValues(["$250 (25%)"])
    self.topRewardText.assertValues(["$5"])
  }

  func testRewardLowBackers() {
    let reward = .template
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 2
      |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 5.0
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 10

    self.vm.inputs.configureWith(country: .us, reward: reward, totalPledged: 10_000)

    self.backersText.assertValues(["2"])
    self.pledgedText.assertValues(["$10 (<1%)"])
    self.topRewardText.assertValues(["$5"])
  }

  func testRewardNoBackers() {
    let reward = .template
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 0
      |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 3.0
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 0

    self.vm.inputs.configureWith(country: .us, reward: reward, totalPledged: 1_000)

    self.backersText.assertValues(["0"])
    self.pledgedText.assertValues(["$0 (0%)"])
    self.topRewardText.assertValues(["$3"])
  }

  func testNoRewardBackers() {
    let reward = .unPledged
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 200
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 200

    self.vm.inputs.configureWith(country: .us, reward: reward, totalPledged: 1_000)

    self.backersText.assertValues(["200"])
    self.pledgedText.assertValues(["$200 (20%)"])
    self.topRewardText.assertValues(["No reward"])
  }

  func testNoRewardLowBackers() {
    let reward = .unPledged
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 2
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 2

    self.vm.inputs.configureWith(country: .us, reward: reward, totalPledged: 10_000)

    self.backersText.assertValues(["2"])
    self.pledgedText.assertValues(["$2 (<1%)"])
    self.topRewardText.assertValues(["No reward"])
  }

  func testNoRewardNoBackers() {
    let reward = ProjectStatsEnvelope.RewardStats.unPledged

    self.vm.inputs.configureWith(country: .us, reward: reward, totalPledged: 1_000)

    self.backersText.assertValues(["0"])
    self.pledgedText.assertValues(["$0 (0%)"])
    self.topRewardText.assertValues(["No reward"])
  }
}
