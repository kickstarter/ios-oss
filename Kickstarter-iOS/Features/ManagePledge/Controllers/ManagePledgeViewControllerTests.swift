@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class ManagePledgeViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
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

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
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

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
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

      assertSnapshot(
        matching: parent.view,
        as: .image(perceptualPrecision: 0.98),
        named: "lang_\(language)_device_\(device)"
      )
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

      assertSnapshot(
        matching: parent.view,
        as: .image(perceptualPrecision: 0.98),
        named: "lang_\(language)_device_\(device)"
      )
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

      assertSnapshot(
        matching: parent.view,
        as: .image(perceptualPrecision: 0.98),
        named: "lang_\(language)_device_\(device)"
      )
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

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
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

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
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

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
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

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_IsBacker_PledgeOverTime_PaymentSchedule_Collapsed() {
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
      |> Backing.lens.paymentIncrements .~ mockPaymentIncrements()

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: user,
        language: language,
        remoteConfigClient: mockConfigClient
      ) {
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

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_IsBacker_PledgeOverTime_PaymentSchedule_Expanded() {
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
      |> Backing.lens.paymentIncrements .~ mockPaymentIncrements()

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode

    let env = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: user,
        language: language,
        remoteConfigClient: mockConfigClient
      ) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        // Network request completes
        self.scheduler.advance()

        controller.plotPaymentScheduleToggle()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_RewardWithImage() {
    let user = User.template
      |> User.lens.id .~ 1

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.remaining .~ 49
      |> Reward.lens.localPickup .~ nil
      |> Reward.lens.image .~ Reward.Image(altText: "The image", url: "https://ksr.com/image.jpg")

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

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: user, language: language) {
        let controller = ManagePledgeViewController.instantiate()
        controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_400

        // Network request completes
        self.scheduler.advance()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        controller.tableView.layoutIfNeeded()
        controller.tableView.reloadData()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
