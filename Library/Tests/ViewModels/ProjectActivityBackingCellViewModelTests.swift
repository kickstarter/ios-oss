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
  private let notifyDelegateGoToBacking = TestObserver<(Project, User), NoError>()
  private let notifyDelegateGoToSendMessage = TestObserver<(Project, Backing), NoError>()
  private let pledgeAmount = TestObserver<String, NoError>()
  private let pledgeAmountLabelIsHidden = TestObserver<Bool, NoError>()
  private let pledgeAmountsStackViewIsHidden = TestObserver<Bool, NoError>()
  private let previousPledgeAmount = TestObserver<String, NoError>()
  private let previousPledgeAmountLabelIsHidden = TestObserver<Bool, NoError>()
  private let reward = TestObserver<String, NoError>()
  private let title = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.backerImageURL.map { $0?.absoluteString }.observe(self.backerImage.observer)
    self.vm.outputs.notifyDelegateGoToBacking.observe(self.notifyDelegateGoToBacking.observer)
    self.vm.outputs.notifyDelegateGoToSendMessage.observe(self.notifyDelegateGoToSendMessage.observer)
    self.vm.outputs.pledgeAmount.observe(self.pledgeAmount.observer)
    self.vm.outputs.pledgeAmountLabelIsHidden.observe(self.pledgeAmountLabelIsHidden.observer)
    self.vm.outputs.pledgeAmountsStackViewIsHidden.observe(self.pledgeAmountsStackViewIsHidden.observer)
    self.vm.outputs.previousPledgeAmount.observe(self.previousPledgeAmount.observer)
    self.vm.outputs.previousPledgeAmountLabelIsHidden.observe(self.previousPledgeAmountLabelIsHidden.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testBackerImage() {
    let project = Project.template
    let user = .template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.backerImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits backer's image URL")
  }

  func testNotifyDelegateGoToBacking() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.notifyDelegateGoToBacking.assertValueCount(0)

    self.vm.inputs.backingButtonPressed()
    self.notifyDelegateGoToBacking.assertValueCount(1, "Should go to backing")
  }

  func testNotifyDelegateGoToSendMessage() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.notifyDelegateGoToSendMessage.assertValueCount(0)

    self.vm.inputs.sendMessageButtonPressed()
    self.notifyDelegateGoToSendMessage.assertValueCount(
      1, "Go to send message after pressing send message button"
    )
  }

  func testPledgeAmount() {
    let project = Project.template
    let backingActivity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.amount .~ 25
      |> Activity.lens.project .~ project
    self.vm.inputs.configureWith(activity: backingActivity, project: project)
    self.pledgeAmount.assertValues(["$25"], "Emits pledge amount")
    self.pledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")

    let backingAmountActivity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.newAmount .~ 15
      |> Activity.lens.memberData.oldAmount .~ 25
      |> Activity.lens.project .~ project
    self.vm.inputs.configureWith(activity: backingAmountActivity, project: project)
    self.pledgeAmount.assertValues(["$25", "$15"], "Emits new pledge amount")
    self.pledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")

    let backingCanceledActivity = .template
      |> Activity.lens.category .~ .backingCanceled
      |> Activity.lens.project .~ project
    self.vm.inputs.configureWith(activity: backingCanceledActivity, project: project)
    self.pledgeAmount.assertValues(["$25", "$15", ""], "Emits empty string when no pledge amount")
    self.pledgeAmountLabelIsHidden.assertValues([false, true], "Hidden when there's no amount")
  }

  func testPreviousPledgeAmount() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.pledgeAmount.assertValues(["$25"], "Emits new plege amount")
    self.pledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")
    self.previousPledgeAmount.assertValues(["$15"], "Emits previous pledge amount")
    self.previousPledgeAmountLabelIsHidden.assertValues([false], "Not hidden when there's an amount")
  }

  func testPledgeAmountsStackViewIsHidden() {
    let project = Project.template
    let activityWithoutAmount = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activityWithoutAmount, project: project)
    self.pledgeAmountsStackViewIsHidden.assertValues([true], "Hidden when there are no amounts.")

    let activityWithAmount = activityWithoutAmount |> Activity.lens.memberData.amount .~ 5
    self.vm.inputs.configureWith(activity: activityWithAmount, project: project)
    self.pledgeAmountsStackViewIsHidden.assertValues([true, false], "Not hidden if there is an amount.")

    let activityWithNewAmount = activityWithoutAmount |> Activity.lens.memberData.newAmount .~ 5
    self.vm.inputs.configureWith(activity: activityWithNewAmount, project: project)
    self.pledgeAmountsStackViewIsHidden.assertValues([true, false], "Not hidden if there is a new amount.")

    let activityWithOldAmount = activityWithoutAmount |> Activity.lens.memberData.oldAmount .~ 5
    self.vm.inputs.configureWith(activity: activityWithOldAmount, project: project)
    self.pledgeAmountsStackViewIsHidden.assertValues([true, false], "Not hidden if there is an old amount.")
  }

  func testReward() {
    let reward1 = .template
      |> Reward.lens.description .~ "Super sick"
      |> Reward.lens.id .~ 32
      |> Reward.lens.title .~ "Sick Skull Graphic Notepad"
    let reward2 = .template
      |> Reward.lens.description .~ "Sick Skull Graphic Binder"
      |> Reward.lens.id .~ 33
    let project = .template
      |> Project.lens.rewards .~ [.noReward, reward1, reward2]

    let activity1 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 32
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity1, project: project)
    let expected1 = Strings.dashboard_activity_reward_name(reward_name: reward1.title!)
    self.reward.assertValues([expected1], "Should emit reward title if present")

    let activity2 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 33
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity2, project: project)
    let expected2 = Strings.dashboard_activity_reward_name(reward_name: reward2.description)
    self.reward.assertValues([expected1, expected2],
                             "Should emit reward description if title not present")

    let activity3 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 0
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity3, project: project)
    let expected3 = Strings.dashboard_activity_no_reward_selected()
    self.reward.assertValues([expected1, expected2, expected3], "Should emit no reward selected")
  }

  func testTitleBacking() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues([Strings.dashboard_activity_user_name_pledged(user_name: "Christopher")],
                            "Should emit that the user pledged")
  }

  func testTitleBackingByCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues([Strings.dashboard_activity_you_pledged()],
                            "Should emit that 'you' pledged")
  }

  func testTitleBackingAmount() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues(
      [Strings.dashboard_activity_user_name_adjusted_their_pledge(user_name: "Christopher")],
      "Should emit that the user adjusted their pledge")
  }

  func testTitleBackingAmountByCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues([Strings.dashboard_activity_you_adjusted_your_pledge()],
                            "Should emit that 'you' adjusted your pledge")
  }

  func testTitleBackingCanceled() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingCanceled
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues(
      [Strings.dashboard_activity_user_name_canceled_their_pledge(user_name: "Christopher")],
      "Should emit that the user canceled their pledge"
    )
  }

  func testTitleBackingCanceledByCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingCanceled
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues([Strings.dashboard_activity_you_canceled_your_pledge()],
                            "Should emit that 'you' canceled your pledge")
  }

  func testTitleBackingReward() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingReward
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.oldRewardId .~ 1
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.newRewardId .~ 2
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ 1001)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ (.template
        |> User.lens.id .~ 1001
        |> User.lens.name .~ "Christopher"
        )
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues(
      [Strings.dashboard_activity_user_name_changed_their_reward(user_name: "Christopher")],
      "Should emit that the user changed their reward"
    )
  }

  func testTitleBackingRewardByCurrentUser() {
    let project = Project.template
    let activity = .template
      |> Activity.lens.category .~ .backingReward
      |> Activity.lens.memberData.oldAmount .~ 15
      |> Activity.lens.memberData.oldRewardId .~ 1
      |> Activity.lens.memberData.newAmount .~ 25
      |> Activity.lens.memberData.newRewardId .~ 2
      |> Activity.lens.memberData.backing .~ (.template |> Backing.lens.backerId .~ self.defaultUser.id)
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ self.defaultUser
    self.vm.inputs.configureWith(activity: activity, project: project)

    self.title.assertValues([Strings.dashboard_activity_you_changed_your_reward()],
                            "Should emit that 'you' changed your reward")
  }
}
