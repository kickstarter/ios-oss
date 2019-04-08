import Foundation
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest

@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let reward = TestObserver<Reward, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reward.observe(self.reward.observer)
  }

  func testRewardOnViewDidLoad() {
    let reward = Reward.template

    self.vm.inputs.configure(with: reward)
    self.vm.inputs.viewDidLoad()

    self.reward.assertValue(reward)
  }
}
