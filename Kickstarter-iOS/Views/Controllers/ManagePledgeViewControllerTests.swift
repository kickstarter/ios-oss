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
      |> User.lens.avatar.small .~ ""

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let backedProject = Project.cosmicSurgery
      |> \.rewards .~ [reward]

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
        expirationDate: "2019-09-01",
        id: "556",
        lastFour: "1111",
        paymentType: .creditCard,
        type: .visa
      )
      |> \.backing.sequence .~ 10
      |> \.backing.location .~ ManagePledgeViewBackingEnvelope.Backing.Location(name: "United States")
      |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
      |> \.backing.amount .~ Money(amount: 10.0, currency: .gbp, symbol: "£")
      |> \.backing.shippingAmount .~ Money(amount: 2.0, currency: .gbp, symbol: "£")
      |> \.backing.backer.uid .~ user.id
      |> \.backing.backer.name .~ "Blob"

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: backedProject
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

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_IsNotBacker_IsCreator() {
    let device = Device.phone4_7inch
    let language = Language.en

    let user = User.template
      |> User.lens.id .~ 1
      |> User.lens.avatar.small .~ ""

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let backedProject = Project.cosmicSurgery
      |> Project.lens.creator.id .~ 1
      |> \.rewards .~ [reward]

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
        expirationDate: "2019-09-01",
        id: "556",
        lastFour: "1111",
        paymentType: .creditCard,
        type: .visa
      )
      |> \.backing.sequence .~ 10
      |> \.backing.location .~ ManagePledgeViewBackingEnvelope.Backing.Location(name: "United States")
      |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
      |> \.backing.amount .~ Money(amount: 10.0, currency: .gbp, symbol: "£")
      |> \.backing.shippingAmount .~ Money(amount: 2.0, currency: .gbp, symbol: "£")
      |> \.backing.backer.uid .~ 5
      |> \.backing.backer.name .~ "Blob"

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: backedProject
    )

    withEnvironment(apiService: mockService, currentUser: user, language: language) {
      let controller = ManagePledgeViewController.instantiate()
      controller.configureWith(params: (Param.slug("project-slug"), Param.id(1)))
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

      // Network request completes
      self.scheduler.advance()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_NoReward_ApplePay() {
    let language = Language.en
    let device = Device.phone4_7inch
    let user = User.template
      |> User.lens.id .~ 1
      |> User.lens.avatar.small .~ ""

    let reward = Reward.noReward

    let backedProject = Project.cosmicSurgery
      |> \.rewards .~ [reward]

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
        expirationDate: "2019-10-01",
        id: "556",
        lastFour: "1111",
        paymentType: .applePay,
        type: .visa
      )
      |> \.backing.sequence .~ 10
      |> \.backing.location .~ nil
      |> \.backing.shippingAmount .~ nil
      |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
      |> \.backing.amount .~ Money(amount: 10.0, currency: .gbp, symbol: "£")
      |> \.backing.backer.uid .~ user.id
      |> \.backing.backer.name .~ "Blob"

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: backedProject
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

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_GooglePay() {
    let language = Language.en
    let device = Device.phone4_7inch
    let user = User.template
      |> User.lens.id .~ 1
      |> User.lens.avatar.small .~ ""

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let backedProject = Project.cosmicSurgery
      |> \.rewards .~ [reward]

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
        expirationDate: "2019-10-01",
        id: "556",
        lastFour: "4111",
        paymentType: .googlePay,
        type: .visa
      )
      |> \.backing.sequence .~ 10
      |> \.backing.location .~ ManagePledgeViewBackingEnvelope.Backing.Location(name: "United States")
      |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
      |> \.backing.amount .~ Money(amount: 10.0, currency: .gbp, symbol: "£")
      |> \.backing.shippingAmount .~ Money(amount: 2.0, currency: .gbp, symbol: "£")
      |> \.backing.backer.uid .~ user.id
      |> \.backing.backer.name .~ "Blob"

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: backedProject
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

      FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
    }
  }

  func testView_ErroredBacking() {
    let user = User.template
      |> User.lens.id .~ 1
      |> User.lens.avatar.small .~ ""

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let backedProject = Project.cosmicSurgery
      |> \.rewards .~ [reward]

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.creditCard .~ ManagePledgeViewBackingEnvelope.Backing.CreditCard(
        expirationDate: "2019-09-01",
        id: "556",
        lastFour: "1111",
        paymentType: .creditCard,
        type: .visa
      )
      |> \.backing.sequence .~ 10
      |> \.backing.location .~ ManagePledgeViewBackingEnvelope.Backing.Location(name: "United States")
      |> \.backing.pledgedOn .~ TimeInterval(1_475_361_315)
      |> \.backing.amount .~ Money(amount: 10.0, currency: .gbp, symbol: "£")
      |> \.backing.shippingAmount .~ Money(amount: 2.0, currency: .gbp, symbol: "£")
      |> \.backing.backer.uid .~ user.id
      |> \.backing.backer.name .~ "Blob"
      |> \.backing.status .~ .errored

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: backedProject
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

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
