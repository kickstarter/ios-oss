import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ManageViewPledgeRewardReceivedViewModelTests: TestCase {
  let vm: ManageViewPledgeRewardReceivedViewModelType = ManageViewPledgeRewardReceivedViewModel()

  let rewardReceived = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.rewardReceived.observe(self.rewardReceived.observer)
  }

  func testRewardReceived_NoBacking() {
    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ nil

    self.vm.inputs.configureWith(project)

    self.rewardReceived.assertValues([false])
  }

  func testRewardReceived_NotReceived() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ false

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)

    self.rewardReceived.assertValues([false])
  }

  func testRewardReceived_Received() {
    let backing = Backing.template
      |> Backing.lens.backerCompleted .~ true

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)

    self.rewardReceived.assertValues([true])
  }
}
