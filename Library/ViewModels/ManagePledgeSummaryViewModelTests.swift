import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ManagePledgeSummaryViewModelTests: TestCase {
  private let vm = ManagePledgeSummaryViewModel()

  private let backerImagePlaceholderImageName = TestObserver<String, Never>()
  private let backerImageURL = TestObserver<URL, Never>()
  private let backerNameLabelHidden = TestObserver<Bool, Never>()
  private let backerNameText = TestObserver<String, Never>()
  private let backerNumberText = TestObserver<String, Never>()
  private let backingDateText = TestObserver<String, Never>()
  private let circleAvatarViewHidden = TestObserver<Bool, Never>()
  private let totalAmountText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.backerImageURLAndPlaceholderImageName.map(second)
      .observe(self.backerImagePlaceholderImageName.observer)
    self.vm.outputs.backerImageURLAndPlaceholderImageName.map(first).observe(self.backerImageURL.observer)
    self.vm.outputs.backerNameLabelHidden.observe(self.backerNameLabelHidden.observer)
    self.vm.outputs.backerNameText.observe(self.backerNameText.observer)
    self.vm.outputs.backerNumberText.observe(self.backerNumberText.observer)
    self.vm.outputs.backingDateText.observe(self.backingDateText.observer)
    self.vm.outputs.circleAvatarViewHidden.observe(self.circleAvatarViewHidden.observer)
    self.vm.outputs.totalAmountText.map { $0.string }
      .observe(self.totalAmountText.observer)
  }

  func testTextOutputsEmitTheCorrectValue() {
    let data = ManagePledgeSummaryViewData(
      backerId: 1,
      backerName: "Backer McGee",
      backerSequence: 999,
      backingState: BackingState.pledged,
      currentUserIsCreatorOfProject: false,
      locationName: nil,
      needsConversion: false,
      omitUSCurrencyCode: true,
      pledgeAmount: 30,
      pledgedOn: 1_568_666_243.0,
      projectCountry: Project.Country.us,
      projectDeadline: 1_572_626_213.0,
      projectState: ProjectState.live,
      shippingAmount: nil
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.backerNumberText.assertValue("Backer #999")
    self.backingDateText.assertValue("As of September 16, 2019")
    self.totalAmountText.assertValue("$30.00")
  }

  func testBackerUserInfo_UserIsBacker() {
    let user = User.template
      |> User.lens.id .~ 123
      |> User.lens.name .~ "Blob"

    let data = ManagePledgeSummaryViewData(
      backerId: 123,
      backerName: "Blob",
      backerSequence: 999,
      backingState: BackingState.pledged,
      currentUserIsCreatorOfProject: false,
      locationName: nil,
      needsConversion: false,
      omitUSCurrencyCode: true,
      pledgeAmount: 30,
      pledgedOn: 1_568_666_243.0,
      projectCountry: Project.Country.us,
      projectDeadline: 1_572_626_213.0,
      projectState: ProjectState.live,
      shippingAmount: nil
    )

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(data)
      self.vm.inputs.viewDidLoad()

      self.backerNameText.assertValues(["Blob"])
      self.backerNameLabelHidden.assertValues([false])
      self.backerImageURL.assertValues([URL(string: "http://www.kickstarter.com/small.jpg")!])
      self.backerImagePlaceholderImageName.assertValues(["avatar--placeholder"])
      self.circleAvatarViewHidden.assertValues([false])
    }
  }

  func testBackerUserInfo_UserIsNotBacker() {
    let user = User.template
      |> User.lens.id .~ 123

    let data = ManagePledgeSummaryViewData(
      backerId: 321,
      backerName: "Backer McGee",
      backerSequence: 999,
      backingState: BackingState.pledged,
      currentUserIsCreatorOfProject: false,
      locationName: nil,
      needsConversion: false,
      omitUSCurrencyCode: true,
      pledgeAmount: 30,
      pledgedOn: 1_568_666_243.0,
      projectCountry: Project.Country.us,
      projectDeadline: 1_572_626_213.0,
      projectState: ProjectState.live,
      shippingAmount: nil
    )

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(data)
      self.vm.inputs.viewDidLoad()

      self.backerNameText.assertDidNotEmitValue()
      self.backerNameLabelHidden.assertValues([true])
      self.backerImageURL.assertDidNotEmitValue()
      self.backerImagePlaceholderImageName.assertDidNotEmitValue()
      self.circleAvatarViewHidden.assertValues([true])
    }
  }
}
