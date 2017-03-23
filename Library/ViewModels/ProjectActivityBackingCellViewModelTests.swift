// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable force_unwrapping
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import Result

internal final class ProjectActivityBackingCellViewModelTests: TestCase {
  fileprivate let vm: ProjectActivityBackingCellViewModelType = ProjectActivityBackingCellViewModel()

  fileprivate let backerImage = TestObserver<String?, NoError>()
  fileprivate let cellAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let cellAccessibilityValue = TestObserver<String, NoError>()
  fileprivate let defaultUser = .template |> User.lens.id .~ 90
  fileprivate let notifyDelegateGoToBacking = TestObserver<(Project, User), NoError>()
  fileprivate let notifyDelegateGoToSendMessage = TestObserver<(Project, Backing), NoError>()
  fileprivate let pledgeAmount = TestObserver<String, NoError>()
  fileprivate let pledgeAmountLabelIsHidden = TestObserver<Bool, NoError>()
  fileprivate let pledgeAmountsStackViewIsHidden = TestObserver<Bool, NoError>()
  fileprivate let pledgeDetailsSeparatorStackViewIsHidden = TestObserver<Bool, NoError>()
  fileprivate let previousPledgeAmount = TestObserver<String, NoError>()
  fileprivate let previousPledgeAmountLabelIsHidden = TestObserver<Bool, NoError>()
  fileprivate let reward = TestObserver<String, NoError>()
  fileprivate let rewardLabelIsHidden = TestObserver<Bool, NoError>()
  fileprivate let title = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.backerImageURL.map { $0?.absoluteString }.observe(self.backerImage.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
    self.vm.outputs.notifyDelegateGoToBacking.observe(self.notifyDelegateGoToBacking.observer)
    self.vm.outputs.notifyDelegateGoToSendMessage.observe(self.notifyDelegateGoToSendMessage.observer)
    self.vm.outputs.pledgeAmount.observe(self.pledgeAmount.observer)
    self.vm.outputs.pledgeAmountLabelIsHidden.observe(self.pledgeAmountLabelIsHidden.observer)
    self.vm.outputs.pledgeAmountsStackViewIsHidden.observe(self.pledgeAmountsStackViewIsHidden.observer)
    self.vm.outputs.pledgeDetailsSeparatorStackViewIsHidden
      .observe(self.pledgeDetailsSeparatorStackViewIsHidden.observer)
    self.vm.outputs.previousPledgeAmount.observe(self.previousPledgeAmount.observer)
    self.vm.outputs.previousPledgeAmountLabelIsHidden.observe(self.previousPledgeAmountLabelIsHidden.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.rewardLabelIsHidden.observe(self.rewardLabelIsHidden.observer)
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

  func testCellAccessibilityLabel() {
    let project = Project.template
    let user = User.template
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.cellAccessibilityLabel.assertValues(
      [Strings.dashboard_activity_user_name_pledged(user_name: user.name).htmlStripped() ?? ""],
      "Emits accessibility label"
    )
  }

  func testCellAccessibilityValueForBacking() {
    let amount = 25
    let title = "Sick Skull Graphic Mousepad"
    let reward = .template
      |> Reward.lens.id .~ 10
      |> Reward.lens.title .~ title
    let project = .template
      |> Project.lens.rewards .~ [reward]
    let user = User.template
    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.amount .~ amount
      |> Activity.lens.memberData.rewardId .~ reward.id
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.Amount_reward(
      amount: Format.currency(amount, country: project.country),
      reward: Strings.dashboard_activity_reward_name(reward_name: title).htmlStripped() ?? "")

    self.cellAccessibilityValue.assertValues([expected], "Emits accessibility value")
  }

  func testCellAccessibilityValueForBackingAmountAndReward() {
    let title = "Sick Skull Graphic Calculator"
    let oldAmount = 15
    let newAmount = 25
    let oldReward = .template
      |> Reward.lens.id .~ 10
    let newReward = .template
      |> Reward.lens.id .~ 11
      |> Reward.lens.title .~ title
    let project = .template
      |> Project.lens.rewards .~ [oldReward, newReward]
    let user = User.template
    let activity = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.oldAmount .~ oldAmount
      |> Activity.lens.memberData.oldRewardId .~ oldReward.id
      |> Activity.lens.memberData.newAmount .~ newAmount
      |> Activity.lens.memberData.newRewardId .~ newReward.id
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    let expected = Strings.Amount_previous_amount(
      amount: Format.currency(newAmount, country: project.country),
                                 previous_amount:  Format.currency(oldAmount,
                                         country: project.country))
    self.cellAccessibilityValue.assertValues([expected], "Emits accessibility value")
  }

  func testCellAccessibilityValueForBackingReward() {
    let title = "Sick Skull Graphic Pen"
    let oldReward = .template
      |> Reward.lens.id .~ 10
    let newReward = .template
      |> Reward.lens.id .~ 11
      |> Reward.lens.title .~ title
    let project = .template
      |> Project.lens.rewards .~ [oldReward, newReward]
    let user = User.template
    let activity = .template
      |> Activity.lens.category .~ .backingReward
      |> Activity.lens.memberData.oldRewardId .~ oldReward.id
      |> Activity.lens.memberData.newRewardId .~ newReward.id
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity, project: project)
    self.cellAccessibilityValue.assertValues(
      [Strings.dashboard_activity_reward_name(reward_name: title).htmlStripped() ?? ""],
      "Emits accessibility value"
    )
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

  func testPledgeDetailsSeparatorStackViewIsHidden() {
    let reward1 = .template
      |> Reward.lens.description .~ "Super sick"
      |> Reward.lens.id .~ 19
      |> Reward.lens.title .~ "Sick Skull Graphic Skateboard"

    let project = .template
      |> Project.lens.rewards .~ [.noReward, reward1]

    let activity1 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 19
      |> Activity.lens.memberData.amount .~ 5
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity1, project: project)
    self.pledgeDetailsSeparatorStackViewIsHidden.assertValues(
      [false],
      "Not hidden when activity has reward and amount"
    )

    let activity2 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 19
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity2, project: project)
    self.pledgeDetailsSeparatorStackViewIsHidden.assertValues(
      [false, true],
      "Hidden when activity has reward but no amount"
    )

    let activity3 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.amount .~ 5
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity3, project: project)
    self.pledgeDetailsSeparatorStackViewIsHidden.assertValues(
      [false, true],
      "Hidden when activity has reward but no amount"
    )
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
    self.rewardLabelIsHidden.assertValues([false])

    let activity2 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ 33
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity2, project: project)
    let expected2 = Strings.dashboard_activity_reward_name(reward_name: reward2.description)
    self.reward.assertValues([expected1, expected2],
                             "Should emit reward description if title not present")
    self.rewardLabelIsHidden.assertValues([false, false])

    let activity3 = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.memberData.rewardId .~ Reward.noReward.id
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity3, project: project)
    let expected3 = Strings.dashboard_activity_no_reward_selected()
    self.reward.assertValues([expected1, expected2, expected3], "Should emit no reward selected")
    self.rewardLabelIsHidden.assertValues([false, false, false])

    let activity4 = .template
      |> Activity.lens.category .~ .backingAmount
      |> Activity.lens.memberData.oldAmount .~ 5
      |> Activity.lens.memberData.newAmount .~ 10
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity4, project: project)
    self.reward.assertValues([expected1, expected2, expected3, ""])
    self.rewardLabelIsHidden.assertValues([false, false, false, true])
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
