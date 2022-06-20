@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class ManagePledgeViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView_CurrentUser_IsBacker() {
    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.remaining .~ 49
      |> Reward.lens.localPickup .~ nil

    let addOns = [Reward.postcards |> Reward.lens.minimum .~ 10]

    let backing = Backing.template
      |> Backing.lens.addOns .~ addOns
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.template

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        // Network request completes
        self.scheduler.advance()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_IsNotBacker_IsCreator() {
    let device = Device.phone4_7inch
    let language = Language.en

    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.localPickup .~ nil

    let addOns = [Reward.postcards |> Reward.lens.minimum .~ 10]

    let backing = Backing.template
      |> Backing.lens.addOns .~ addOns
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.template

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.creator.id .~ 1

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    withEnvironment(apiService: mockService, currentUser: user, language: language) {
      let controller = ManagePledgeViewController.instantiate()
      controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

      // Network request completes
      self.scheduler.advance()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      controller.tableView.layoutIfNeeded()
      controller.tableView.reloadData()

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_NoReward_ApplePay() {
    let language = Language.en
    let device = Device.phone4_7inch

    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.localPickup .~ nil

    let addOns = [Reward.postcards |> Reward.lens.minimum .~ 10]

    let backing = Backing.template
      |> Backing.lens.addOns .~ addOns
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.paymentSource .~ (
        Backing.PaymentSource.template
          |> \.paymentType .~ .applePay
      )

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    withEnvironment(apiService: mockService, currentUser: user, language: language) {
      let controller = ManagePledgeViewController.instantiate()
      controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: controller
      )

      // Network request completes
      self.scheduler.advance()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      controller.tableView.layoutIfNeeded()
      controller.tableView.reloadData()

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_GooglePay() {
    let language = Language.en
    let device = Device.phone4_7inch

    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.localPickup .~ nil

    let addOns = [Reward.postcards |> Reward.lens.minimum .~ 10]

    let backing = Backing.template
      |> Backing.lens.addOns .~ addOns
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.paymentSource .~ (
        Backing.PaymentSource.template
          |> \.paymentType .~ .googlePay
      )

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    withEnvironment(apiService: mockService, currentUser: user, language: language) {
      let controller = ManagePledgeViewController.instantiate()
      controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
      let (parent, _) = traitControllers(
        device: device,
        orientation: .portrait,
        child: controller
      )

      // Network request completes
      self.scheduler.advance()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      controller.tableView.layoutIfNeeded()
      controller.tableView.reloadData()

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_ErroredBacking() {
    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.remaining .~ 49
      |> Reward.lens.localPickup .~ nil

    let addOns = [Reward.postcards |> Reward.lens.minimum .~ 10]

    let backing = Backing.template
      |> Backing.lens.addOns .~ addOns
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.template
      |> Backing.lens.status .~ .errored

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        // Network request completes
        self.scheduler.advance()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_IsBacker_LocalPickupsForAddonsAndBaseReward_Success() {
    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.remaining .~ 49
      |> Reward.lens.localPickup .~ .brooklyn
      |> Reward.lens.shipping.preference .~ .local

    let addOns = [
      Reward.postcards
        |> Reward.lens.minimum .~ 10
        |> Reward.lens.localPickup .~ .brooklyn
        |> Reward.lens.shipping.preference .~ .local
        |> Reward.lens.rewardsItems .~ []
        |> Reward.lens.shipping.enabled .~ false
    ]

    let backing = Backing.template
      |> Backing.lens.addOns .~ addOns
      |> Backing.lens.amount .~ 22
      |> Backing.lens.reward .~ reward
      |> Backing.lens.rewardId .~ reward.id
      |> Backing.lens.paymentSource .~ Backing.PaymentSource.template

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_600

        // Network request completes
        self.scheduler.advance()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
