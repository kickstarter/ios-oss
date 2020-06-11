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
  private let cornerRadius = TestObserver<CGFloat, Never>()
  private let layoutMargins = TestObserver<UIEdgeInsets, Never>()
  private let marginWidth = TestObserver<CGFloat, Never>()
  private let rewardReceived = TestObserver<Bool, Never>()
  private let rewardReceivedHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.estimatedDeliveryDateLabelAttributedText
      .map { $0.string }
      .observe(self.estimatedDeliveryDateLabelAttributedText.observer)
    self.vm.outputs.cornerRadius.observe(self.cornerRadius.observer)
    self.vm.outputs.layoutMargins.observe(self.layoutMargins.observer)
    self.vm.outputs.marginWidth.observe(self.marginWidth.observer)
    self.vm.outputs.rewardReceived.observe(self.rewardReceived.observer)
    self.vm.outputs.rewardReceivedHidden.observe(self.rewardReceivedHidden.observer)
  }

  func testEstimatedDeliveryDateLabelAttributedText() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged
    )

    self.estimatedDeliveryDateLabelAttributedText.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.estimatedDeliveryDateLabelAttributedText.assertValues(["Estimated delivery October 2016"])
  }

  func testLayoutMargins_NotCollected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged
    )

    self.layoutMargins.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.layoutMargins.assertValues([.zero])
  }

  func testLayoutMargins_Collected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected
    )

    self.layoutMargins.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.layoutMargins.assertValues([.init(all: Styles.gridHalf(5))])
  }

  func testCornerRadius_NotCollected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged
    )

    self.cornerRadius.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.cornerRadius.assertValues([0])
  }

  func testCornerRadius_Collected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected
    )

    self.cornerRadius.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.cornerRadius.assertValues([Styles.grid(2)])
  }

  func testMarginWidth_NotCollected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged
    )

    self.marginWidth.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.marginWidth.assertValues([0])
  }

  func testMarginWidth_Collected() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let data = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected
    )

    self.marginWidth.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.marginWidth.assertValues([1])
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
      backingState: .pledged
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
      backingState: .pledged
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
      backingState: .pledged
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
      backingState: .dropped
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
      backingState: .pledged
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
      backingState: .preauth
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
      backingState: .canceled
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
      backingState: .dropped
    )

    self.rewardReceivedHidden.assertDidNotEmitValue()

    self.vm.inputs.configureWith(data)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.rewardReceivedHidden.assertValues([true])
  }
}
