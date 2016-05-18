import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import Models_TestHelpers
import ReactiveCocoa
import Result
import Models

internal final class BackingCellViewModelTests: TestCase {
  private let vm: BackingCellViewModelType = BackingCellViewModel()

  private let pledged = TestObserver<String, NoError>()
  private let reward = TestObserver<String, NoError>()
  private let delivery = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pledged.observe(self.pledged.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.delivery.observe(self.delivery.observer)
  }

  func testOutputs() {
    let backing = BackingFactory.backing()
    self.vm.inputs.configureWith(backing: backing, project: ProjectFactory.live())

    self.pledged.assertValueCount(1)
    self.reward.assertValues([(backing.reward?.description)!])
    self.delivery.assertValueCount(1)
  }
}
