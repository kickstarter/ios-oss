import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result

internal final class ProjectActivityBackingCellViewModelTests: TestCase {
  private let vm: ProjectActivityBackingCellViewModelType = ProjectActivityBackingCellViewModel()

  private let backerImage = TestObserver<String?, NoError>()
  private let defaultUser = .template |> User.lens.id .~ 90
  private let goToBackingInfo = TestObserver<Backing, NoError>()
  private let goToSendMessage = TestObserver<(Project, Backing), NoError>()
  private let pledgeAmount = TestObserver<String, NoError>()
  private let pledgeAmountLabelIsHidden = TestObserver<Bool, NoError>()
  private let previousPledgeAmount = TestObserver<String, NoError>()
  private let previousPledgeAmountLabelIsHidden = TestObserver<Bool, NoError>()
  private let reward = TestObserver<String, NoError>()
  private let title = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.backerImageURL.map { $0?.absoluteString }.observe(self.backerImage.observer)
    self.vm.outputs.goToBackingInfo.observe(self.goToBackingInfo.observer)
    self.vm.outputs.goToSendMessage.observe(self.goToSendMessage.observer)
    self.vm.outputs.pledgeAmount.observe(self.pledgeAmount.observer)
    self.vm.outputs.pledgeAmountLabelIsHidden.observe(self.pledgeAmountLabelIsHidden.observer)
    self.vm.outputs.previousPledgeAmount.observe(self.previousPledgeAmount.observer)
    self.vm.outputs.previousPledgeAmountLabelIsHidden.observe(self.previousPledgeAmountLabelIsHidden.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testBackerImage() {
    let user = .template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity)
    self.backerImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits backer's image URL")
  }

  func testGoToBackingInfo() {
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ .template

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.backingInfoButtonPressed()
    self.goToBackingInfo.assertValues([activity.memberData.backing!], "Emits backing from activity")
  }

  func testGoToSendMessage() {
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ .template

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.sendMessageButtonPressed()
    self.goToSendMessage.assertValueCount(1, "Go to send message after pressing send message button")
  }

  func testPledgeAmount() {
    let backingActivity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.amount .~ 25
    self.vm.inputs.configureWith(activity: backingActivity)
    self.pledgeAmount.assertValues(["$25"], "Emits pledge amount")
    self.pledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")

    let backingAmountActivity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.newAmount .~ 15
      |> Activity.lens.memberData.oldAmount .~ 25
    self.vm.inputs.configureWith(activity: backingAmountActivity)
    self.pledgeAmount.assertValues(["$25", "$15"], "Emits new pledge amount")
    self.pledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")

    let backingCanceledActivity = .template
      |> Activity.lens.category .~ .backingCanceled
    self.vm.inputs.configureWith(activity: backingCanceledActivity)
    self.pledgeAmount.assertValues(["$25", "$15", ""], "Emits empty string when no pledge amount")
    self.pledgeAmountLabelIsHidden.assertValues([false, true], "Hidden when there's no amount")
  }

  func testPreviousPledgeAmount() {
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.oldAmount .~ 15

    self.vm.inputs.configureWith(activity: activity)
    self.pledgeAmount.assertValues(["$25"], "Emits new plege amount")
    self.pledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")
    self.previousPledgeAmount.assertValues(["$15"], "Emits previous pledge amount")
    self.previousPledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")
  }

  func testReward() {
    let reward1 = .template
      |> Reward.lens.description .~ "Super sick"
      |> Reward.lens.id .~ 32
      |> Reward.lens.title .~ "Sick Skull Graphic Notepad"
    let activity1 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 32
      |> Activity.lens.project .~ (.template |> Project.lens.rewards .~ [reward1])

    self.vm.inputs.configureWith(activity: activity1)
    self.reward.assertValues([reward1.title!], "Should emit reward title if present")

    let reward2 = .template
      |> Reward.lens.description .~ "Sick Skull Graphic Notepad"
      |> Reward.lens.id .~ 33
    let activity2 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 33
      |> Activity.lens.project .~ (.template |> Project.lens.rewards .~ [reward2])

    self.vm.inputs.configureWith(activity: activity2)
    self.reward.assertValues([reward1.title!, reward2.description],
                             "Should emit reward description if title not present")
  }

  func testTitleBacking() {
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues([Strings.activity_creator_actions_user_name_pledged(user_name: "Christopher")],
                            "Should emit that the user pledged")
  }

  func testTitleBackingByCurrentUser() {
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues([Strings.activity_creator_actions_you_pledged()],
                            "Should emit that 'you' pledged")
  }

  func testTitleBackingAmount() {
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues(
      [Strings.activity_creator_actions_user_name_adjusted_their_pledge(user_name: "Christopher")],
      "Should emit that the user adjusted their pledge")
  }

  func testTitleBackingAmountByCurrentUser() {
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues([Strings.activity_creator_actions_you_adjusted_your_pledge()],
                            "Should emit that 'you' adjusted your pledge")
  }

  func testTitleBackingCanceled() {
    let activity = .template
      |> Activity.lens.category .~ .backingCanceled
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues(
      [Strings.activity_creator_actions_user_name_canceled_their_pledge(user_name: "Christopher")],
      "Should emit that the user canceled their pledge"
    )
  }

  func testTitleBackingCanceledByCurrentUser() {
    let activity = .template
      |> Activity.lens.category .~ .backingCanceled
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues([Strings.activity_creator_actions_you_canceled_your_pledge()],
                            "Should emit that 'you' canceled your pledge")
  }

  func testTitleBackingReward() {
    let activity = .template
      |> Activity.lens.category .~ .backingReward
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.oldRewardId .~ 1
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.newRewardId .~ 2
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues(
      [Strings.activity_creator_actions_user_name_changed_their_reward(user_name: "Christopher")],
      "Should emit that the user changed their reward"
    )
  }

  func testTitleBackingRewardByCurrentUser() {
    let activity = .template
      |> Activity.lens.category .~ .backingReward
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.oldRewardId .~ 1
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.newRewardId .~ 2
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity)

    self.title.assertValues([Strings.activity_creator_actions_you_changed_your_reward()],
                            "Should emit that 'you' changed your reward")
  }
}
