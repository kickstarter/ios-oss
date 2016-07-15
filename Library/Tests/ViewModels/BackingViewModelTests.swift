import Library
import Prelude
import ReactiveCocoa
import Result
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

internal final class BackingViewModelTests: TestCase {
  internal let vm: BackingViewModelType = BackingViewModel()

  internal let backerAvatarURL = TestObserver<String?, NoError>()
  internal let backerName = TestObserver<String, NoError>()
  internal let backerSequence = TestObserver<String, NoError>()
  internal let backerPledgeAmountAndDate = TestObserver<String, NoError>()
  internal let backerPledgeStatus = TestObserver<String, NoError>()
  internal let backerRewardDescription = TestObserver<String, NoError>()
  internal let backerShippingCost = TestObserver<String, NoError>()
  internal let backerShippingDescription = TestObserver<String, NoError>()
  internal let goToMessagesBacking = TestObserver<Backing, NoError>()
  internal let goToMessagesProject = TestObserver<Project, NoError>()
  internal let presentMessageDialog = TestObserver<MessageThread, NoError>()

  override func setUp() {
    super.setUp()
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "hello", user: User.template))
    self.vm.outputs.backerAvatarURL.map { $0?.absoluteString }.observe(backerAvatarURL.observer)
    self.vm.outputs.backerName.observe(backerName.observer)
    self.vm.outputs.backerSequence.observe(backerSequence.observer)
    self.vm.outputs.backerPledgeAmountAndDate.observe(backerPledgeAmountAndDate.observer)
    self.vm.outputs.backerPledgeStatus.observe(backerPledgeStatus.observer)
    self.vm.outputs.backerRewardDescription.observe(backerRewardDescription.observer)
    self.vm.outputs.backerShippingCost.observe(backerShippingCost.observer)
    self.vm.outputs.backerShippingDescription.observe(backerShippingDescription.observer)
    self.vm.outputs.goToMessages.map(first).observe(goToMessagesProject.observer)
    self.vm.outputs.goToMessages.map(second).observe(goToMessagesBacking.observer)
  }

  func testBackerAvatarURL() {
    withEnvironment(currentUser: .template |> User.lens.avatar.small .~ "http://www.image.com/lit.jpg") {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerAvatarURL.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerAvatarURL.assertValues(["http://www.image.com/lit.jpg"], "User avatar emitted")
    }
  }

  func testUserName() {
    withEnvironment(currentUser: .template |> User.lens.name .~ "Carla") {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerName.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerName.assertValues(["Carla"], "Name should be Carla")
    }
  }

  func testBackerName() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template,
                                   backer: .template |> User.lens.name .~ "Swanson")

      self.backerName.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerName.assertValues(["Swanson"], "Name should be Swanson")
    }
  }

  func testBackerSequence() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template |> Backing.lens.sequence .~ 5)) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerSequence.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerSequence.assertValues([Strings.backer_modal_backer_number(backer_number: "5")],
                                       "Backer label emits backer sequence")
    }
  }

  func testBackerPledgeAmountAndDate() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.amount .~ 35
      |> Backing.lens.pledgedAt .~ 1468527587.32843 )) {
      self.vm.inputs.configureWith(project: .template |> Project.lens.country .~ .US, backer: nil)

      self.backerPledgeAmountAndDate.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerPledgeAmountAndDate.assertValues(["$35 on July 14, 2016"],
                                                  "Backer label emits pledge amount")
    }
  }

  func testBackerPledgeStatus() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.status .~ .pledged)) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerPledgeStatus.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerPledgeStatus.assertValues(["Status: Pledged"], "Backer label emits pledge status")
    }
  }

  func testBackerRewardDescription() {
    let reward = .template |> Reward.lens.description .~ "Cool Item"

      withEnvironment(apiService: MockService (fetchBackingResponse: .template
        |> Backing.lens.amount .~ 10_00
        |> Backing.lens.reward .~ reward)) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerRewardDescription.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerRewardDescription.assertValues(["$10 - Cool Item"], "Backer label emits reward description")
    }
  }

  func testBackerShippingCost() {
    withEnvironment(apiService: MockService (fetchBackingResponse: .template
      |> Backing.lens.shippingAmount .~ 37)) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerShippingCost.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerShippingCost.assertValues(["$37"], "Backer label emits shipping cost") //change to amount
    }
  }

  func testBackerShippingDescription() {
    let shipping = Reward.Shipping(
      enabled: true,
      preference: .none,
      summary: "Ships only to Litville, Legitas"
    )

    withEnvironment(apiService: MockService (fetchBackingResponse: .template
      |> Backing.lens.reward .~ (.template |> Reward.lens.shipping .~ shipping))) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerShippingDescription.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerShippingDescription.assertValues([ "Ships only to Litville, Legitas"],
                                                  "Backer label emits reward description")
    }
  }

  func testGoToMessages() {
    let project = Project.template
    let backing = Backing.template

    withEnvironment(apiService: MockService(fetchBackingResponse: backing)) {
      self.vm.inputs.configureWith(project: project, backer: nil)

      self.vm.inputs.viewDidLoad()

      self.goToMessagesProject.assertValues([])
      self.goToMessagesBacking.assertValues([])

      self.vm.inputs.viewMessagesTapped()

      self.goToMessagesProject.assertValues([project])
      self.goToMessagesBacking.assertValues([backing])
    }
  }
}
