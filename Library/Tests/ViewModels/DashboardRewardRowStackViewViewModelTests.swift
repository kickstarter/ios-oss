import XCTest
import Result
import ReactiveCocoa
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

  // swiftlint:disable type_name
internal final class DashboardRewardRowStackViewViewModelTests: TestCase {
  // swiftlint:enable type_name
  let vm: DashboardRewardRowStackViewViewModelType = DashboardRewardRowStackViewViewModel()

  let backersText = TestObserver<String, NoError>()
  let percentText = TestObserver<String, NoError>()
  let pledgedText = TestObserver<String, NoError>()
  let topRewardText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.backersText.observe(backersText.observer)
    vm.outputs.percentText.observe(percentText.observer)
    vm.outputs.pledgedText.observe(pledgedText.observer)
    vm.outputs.topRewardText.observe(topRewardText.observer)
  }

  func testRewardBackers() {
    let reward = .template
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 50
      |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 250

    self.vm.inputs.configureWith(country: .US, reward: reward, totalPledged: 1000)

    self.backersText.assertValues(["50"])
    self.percentText.assertValues(["25%"])
    self.pledgedText.assertValues(["$250"])
    self.topRewardText.assertValues(["$5"])
  }

  func testRewardLowBackers() {
    let reward = .template
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 2
      |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 10

    self.vm.inputs.configureWith(country: .US, reward: reward, totalPledged: 10000)

    self.backersText.assertValues(["2"])
    self.percentText.assertValues(["<1%"])
    self.pledgedText.assertValues(["$10"])
    self.topRewardText.assertValues(["$5"])
  }

  func testRewardNoBackers() {
    let reward = .template
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 0
      |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
      |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 3
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 0

    self.vm.inputs.configureWith(country: .US, reward: reward, totalPledged: 1000)

    self.backersText.assertValues(["0"])
    self.percentText.assertValues(["0%"])
    self.pledgedText.assertValues(["$0"])
    self.topRewardText.assertValues(["$3"])
  }

  func testNoRewardBackers() {
    let reward = .unPledged
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 200
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 200

    self.vm.inputs.configureWith(country: .US, reward: reward, totalPledged: 1000)

    self.backersText.assertValues(["200"])
    self.percentText.assertValues(["20%"])
    self.pledgedText.assertValues(["$200"])
    self.topRewardText.assertValues(["No reward"])
  }

  func testNoRewardLowBackers() {
    let reward = .unPledged
      |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 2
      |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 2

    self.vm.inputs.configureWith(country: .US, reward: reward, totalPledged: 10000)

    self.backersText.assertValues(["2"])
    self.percentText.assertValues(["<1%"])
    self.pledgedText.assertValues(["$2"])
    self.topRewardText.assertValues(["No reward"])
  }

  func testNoRewardNoBackers() {
    let reward = ProjectStatsEnvelope.RewardStats.unPledged

    self.vm.inputs.configureWith(country: .US, reward: reward, totalPledged: 1000)

    self.backersText.assertValues(["0"])
    self.percentText.assertValues(["0%"])
    self.pledgedText.assertValues(["$0"])
    self.topRewardText.assertValues(["No reward"])
  }
}
