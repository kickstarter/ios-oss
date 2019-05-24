import ReactiveSwift
import ReactiveExtensions
import XCTest
import Result
@testable import KsApi
import ReactiveExtensions_TestHelpers
@testable import Library

final class RewardsCollectionViewModelTests: TestCase {
  private let vm: RewardsCollectionViewModelType = RewardsCollectionViewModel()

  private let goToPledgeProject = TestObserver<Project, NoError>()
  private let goToPledgeRefTag = TestObserver<RefTag?, NoError>()
  private let goToPledgeReward = TestObserver<Reward, NoError>()
  private let reloadDataWithRewards = TestObserver<[Reward], NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToPledge.map { $0.project }.observe(self.goToPledgeProject.observer)
    self.vm.outputs.goToPledge.map { $0.reward }.observe(self.goToPledgeReward.observer)
    self.vm.outputs.goToPledge.map { $0.refTag }.observe(self.goToPledgeRefTag.observer)
    self.vm.outputs.reloadDataWithRewards.observe(self.reloadDataWithRewards.observer)
  }

  func testConfigureWithProject() {
    let project = Project.cosmicSurgery
    let rewardsCount = project.rewards.count

    self.vm.inputs.configure(with: project, refTag: RefTag.category)

    self.reloadDataWithRewards.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.reloadDataWithRewards.assertDidEmitValue()

    let value = self.reloadDataWithRewards.values.last

    XCTAssertTrue(value?.count == rewardsCount)
  }

  func testGoToPledge() {
    let project = Project.cosmicSurgery

    self.vm.inputs.configure(with: project, refTag: .activity)
    self.vm.inputs.viewDidLoad()

    self.goToPledgeProject.assertDidNotEmitValue()
    self.goToPledgeReward.assertDidNotEmitValue()
    self.goToPledgeRefTag.assertDidNotEmitValue()

    self.vm.inputs.rewardSelected(at: 0)

    self.goToPledgeProject.assertValues([project])
    self.goToPledgeReward.assertValues([project.rewards[0]])
    self.goToPledgeRefTag.assertValues([.activity])

    let endIndex = project.rewards.endIndex

    self.vm.inputs.rewardSelected(at: endIndex - 1)

    self.goToPledgeProject.assertValues([project, project])
    self.goToPledgeReward.assertValues([project.rewards[0], project.rewards[endIndex - 1]])
    self.goToPledgeRefTag.assertValues([.activity, .activity])
  }
}
