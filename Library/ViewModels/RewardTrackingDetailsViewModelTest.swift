@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardTrackingDetailsViewModelTest: TestCase {
  private let vm: RewardTrackingDetailsViewModelType = RewardTrackingDetailsViewModel()

  private var rewardTrackingStatus = TestObserver<String, Never>()
  private var rewardTrackingNumber = TestObserver<String, Never>()
  private var trackShipping = TestObserver<URL, Never>()

  private let testTrackingNumber = "1234567890"
  private let testURL = URL(string: "http://ksr.com")!

  override func setUp() {
    super.setUp()

    self.vm.outputs.rewardTrackingStatus.observe(self.rewardTrackingStatus.observer)
    self.vm.outputs.rewardTrackingNumber.observe(self.rewardTrackingNumber.observer)
    self.vm.outputs.trackShipping.observe(self.trackShipping.observer)
  }

  func testView_BackingDetails_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL
    )

    self.vm.inputs.configure(with: data)
    self.trackShipping.assertDidNotEmitValue()

    self.rewardTrackingNumber.assertLastValue(Strings.Tracking_number(number: "1234567890"))
    self.rewardTrackingStatus.assertLastValue(Strings.Your_reward_has_shipped())
  }

  func testView_Activity_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL
    )

    self.vm.inputs.configure(with: data)
    self.trackShipping.assertDidNotEmitValue()

    self.rewardTrackingNumber.assertLastValue(Strings.Tracking_number(number: "1234567890"))
    self.rewardTrackingStatus.assertLastValue(Strings.Your_reward_has_shipped())
  }

  func testTrackingButtonTapped() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.trackingButtonTapped()

    self.trackShipping.assertValues([self.testURL])
  }
}
