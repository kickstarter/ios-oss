import ReactiveSwift
import ReactiveExtensions
import XCTest
import Result
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class RewardsCollectionViewModelTests: TestCase {
  private let vm: RewardsCollectionViewModelType = RewardsCollectionViewModel()

  private let reloadDataWithRewards = TestObserver<[Reward], NoError>()

  override func setUp() {
    super.setUp()

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
}
