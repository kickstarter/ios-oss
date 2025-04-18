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
  private var shippingDays = TestObserver<String, Never>()

  private let testTrackingNumber = "1234567890"
  private let testURL = URL(string: "http://ksr.com")!
  // Mocked shipping date: 2 days ago from the current mock date
  private lazy var shippingDate: TimeInterval = {
    MockDate().addingTimeInterval(-2 * 24 * 60 * 60).timeIntervalSince1970
  }()

  override func setUp() {
    super.setUp()

    self.vm.outputs.rewardTrackingStatus.observe(self.rewardTrackingStatus.observer)
    self.vm.outputs.rewardTrackingNumber.observe(self.rewardTrackingNumber.observer)
    self.vm.outputs.trackShipping.observe(self.trackShipping.observer)
    self.vm.outputs.shippingDays.observe(self.shippingDays.observer)
  }

  func testView_BackingDetails_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      shippingDate: self.shippingDate
    )

    self.vm.inputs.configure(with: data)
    self.trackShipping.assertDidNotEmitValue()

    self.rewardTrackingNumber.assertLastValue(Strings.Tracking_number(number: "1234567890"))
    self.rewardTrackingStatus.assertLastValue(Strings.Your_reward_has_shipped())
  }

  func testView_Activity_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      shippingDate: self.shippingDate
    )

    self.vm.inputs.configure(with: data)
    self.trackShipping.assertDidNotEmitValue()

    self.rewardTrackingNumber.assertLastValue(Strings.Tracking_number(number: "1234567890"))
    self.rewardTrackingStatus.assertLastValue(Strings.Your_reward_has_shipped())
    self.shippingDays.assertLastValue(Strings.dates_time_days_ago(time_count: 2))
  }

  func testTrackingButtonTapped() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      shippingDate: self.shippingDate
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.trackingButtonTapped()

    self.trackShipping.assertValues([self.testURL])
  }
}
