import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ManageViewPledgeRewardReceivedViewModelTests: TestCase {
  private let vm: ManageViewPledgeRewardReceivedViewModelType = ManageViewPledgeRewardReceivedViewModel()

  private let estimatedDeliveryDateLabelAttributedText = TestObserver<String, Never>()
  private let estimatedShippingAttributedText = TestObserver<String, Never>()
  private let cornerRadius = TestObserver<CGFloat, Never>()
  private let layoutMargins = TestObserver<UIEdgeInsets, Never>()
  private let marginWidth = TestObserver<CGFloat, Never>()
  private let rewardReceived = TestObserver<Bool, Never>()
  private let rewardReceivedHidden = TestObserver<Bool, Never>()
  private let pledgeDisclaimerViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.estimatedDeliveryDateLabelAttributedText
      .map { $0.string }
      .observe(self.estimatedDeliveryDateLabelAttributedText.observer)
    self.vm.outputs.estimatedShippingAttributedText
      .map { $0.string }
      .observe(self.estimatedShippingAttributedText.observer)
    self.vm.outputs.cornerRadius.observe(self.cornerRadius.observer)
    self.vm.outputs.layoutMargins.observe(self.layoutMargins.observer)
    self.vm.outputs.marginWidth.observe(self.marginWidth.observer)
    self.vm.outputs.rewardReceived.observe(self.rewardReceived.observer)
    self.vm.outputs.rewardReceivedHidden.observe(self.rewardReceivedHidden.observer)
    self.vm.outputs.pledgeDisclaimerViewHidden.observe(self.pledgeDisclaimerViewHidden.observer)
  }

  func testAttributedText() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged,
      estimatedShipping: "About $1-$10",
      pledgeDisclaimerViewHidden: false
    )

    self.estimatedDeliveryDateLabelAttributedText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.estimatedDeliveryDateLabelAttributedText.assertValues(["Estimated delivery October 2016"])
    self.estimatedShippingAttributedText.assertValues(["Estimated Shipping About $1-$10"])
  }

  func testRewardReceived_NotReceived() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.rewardReceived.assertValues([false])
  }

  func testRewardReceived_Received() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ true

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: true,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.rewardReceived.assertValues([true])
  }

  func testRewardReceived_Toggle() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    withEnvironment(apiService: MockService(backingUpdate: .template), currentUser: User.template) {
      self.vm.inputs.configureWith(data)
      self.vm.inputs.viewDidLoad()

      self.rewardReceived.assertValues([false])

      self.vm.inputs.rewardReceivedToggleTapped(isOn: true)

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      self.rewardReceived.assertValues([false, true])

      self.vm.inputs.rewardReceivedToggleTapped(isOn: false)

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      self.rewardReceived.assertValues([false, true, false])
    }
  }

  func testRewardReceivedHidden_Dropped() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .dropped,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.rewardReceivedHidden.assertValues([true])
  }

  func testRewardReceivedHidden_Pledged() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.rewardReceivedHidden.assertValues([true])
  }

  func testRewardReceivedHidden_Preauth() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .preauth,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.rewardReceivedHidden.assertValues([true])
  }

  func testRewardReceivedHidden_Canceled() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .canceled,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.rewardReceivedHidden.assertValues([true])
  }

  func testRewardReceivedHidden_Collected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .dropped,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: false
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.rewardReceivedHidden.assertValues([true])
  }

  func testPledgeDisclaimerViewHidden() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .dropped,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: true
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.pledgeDisclaimerViewHidden.assertValues([true])
  }
}
