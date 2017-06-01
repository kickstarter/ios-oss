// swiftlint:disable force_unwrapping
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class BackingViewModelTests: TestCase {
  internal let vm: BackingViewModelType = BackingViewModel()

  internal let backerAvatarURL = TestObserver<String?, NoError>()
  internal let backerName = TestObserver<String, NoError>()
  internal let backerNameAccessibilityLabel = TestObserver<String, NoError>()
  internal let backerSequence = TestObserver<String, NoError>()
  internal let backerSequenceAccessibilityLabel = TestObserver<String, NoError>()
  internal let backerPledgeAmountAndDate = TestObserver<String, NoError>()
  internal let backerPledgeAmountAndDateAccessibilityLabel = TestObserver<String, NoError>()
  internal let backerPledgeStatus = TestObserver<String, NoError>()
  internal let backerPledgeStatusAccessibilityLabel = TestObserver<String, NoError>()
  internal let backerRewardDescription = TestObserver<String, NoError>()
  internal let backerRewardDescriptionAccessibilityLabel = TestObserver<String, NoError>()
  internal let backerShippingAmount = TestObserver<String, NoError>()
  internal let backerShippingAmountAccessibilityLabel = TestObserver<String, NoError>()
  internal let backerShippingDescription = TestObserver<String, NoError>()
  internal let backerShippingDescriptionAccessibilityLabel = TestObserver<String, NoError>()
  internal let estimatedDeliveryDateLabelText = TestObserver<String, NoError>()
  internal let goToMessageCreatorSubject = TestObserver<MessageSubject, NoError>()
  internal let goToMessageCreatorContext = TestObserver<Koala.MessageDialogContext, NoError>()
  internal let goToMessagesBacking = TestObserver<Backing, NoError>()
  internal let goToMessagesProject = TestObserver<Project, NoError>()
  internal let hideActionsStackView = TestObserver<Bool, NoError>()
  internal let presentMessageDialog = TestObserver<MessageThread, NoError>()
  internal let messageButtonTitleText = TestObserver<String, NoError>()
  internal let loadingOverlayIsHidden = TestObserver<Bool, NoError>()
  internal let rootStackViewAxis = TestObserver<UILayoutConstraintAxis, NoError>()

  override func setUp() {
    super.setUp()
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "hello", user: .template))
    self.vm.outputs.backerAvatarURL.map { $0?.absoluteString }.observe(backerAvatarURL.observer)
    self.vm.outputs.backerName.observe(backerName.observer)
    self.vm.outputs.backerNameAccessibilityLabel.observe(backerNameAccessibilityLabel.observer)
    self.vm.outputs.backerSequence.observe(backerSequence.observer)
    self.vm.outputs.backerSequenceAccessibilityLabel.observe(backerSequenceAccessibilityLabel.observer)
    self.vm.outputs.backerPledgeAmountAndDate.observe(backerPledgeAmountAndDate.observer)
    self.vm.outputs.backerPledgeAmountAndDateAccessibilityLabel
      .observe(backerPledgeAmountAndDateAccessibilityLabel.observer)
    self.vm.outputs.backerPledgeStatus.observe(backerPledgeStatus.observer)
    self.vm.outputs.backerPledgeStatusAccessibilityLabel
      .observe(backerPledgeStatusAccessibilityLabel.observer)
    self.vm.outputs.backerRewardDescription.observe(backerRewardDescription.observer)
    self.vm.outputs.backerRewardDescriptionAccessibilityLabel
      .observe(backerRewardDescriptionAccessibilityLabel.observer)
    self.vm.outputs.backerShippingAmount.observe(backerShippingAmount.observer)
    self.vm.outputs.backerShippingAmountAccessibilityLabel
      .observe(backerShippingAmountAccessibilityLabel.observer)
    self.vm.outputs.backerShippingDescription.observe(backerShippingDescription.observer)
    self.vm.outputs.backerShippingDescriptionAccessibilityLabel
      .observe(backerShippingDescriptionAccessibilityLabel.observer)
    self.vm.outputs.estimatedDeliveryDateLabelText.observe(estimatedDeliveryDateLabelText.observer)
    self.vm.outputs.goToMessageCreator.map(first).observe(goToMessageCreatorSubject.observer)
    self.vm.outputs.goToMessageCreator.map(second).observe(goToMessageCreatorContext.observer)
    self.vm.outputs.goToMessages.map(first).observe(goToMessagesProject.observer)
    self.vm.outputs.goToMessages.map(second).observe(goToMessagesBacking.observer)
    self.vm.outputs.hideActionsStackView.observe(hideActionsStackView.observer)
    self.vm.outputs.messageButtonTitleText.observe(messageButtonTitleText.observer)
    self.vm.outputs.loadingOverlayIsHidden.observe(loadingOverlayIsHidden.observer)
    self.vm.outputs.rootStackViewAxis.observe(rootStackViewAxis.observer)
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

  func testBackerNameAccessibilityLabel() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template,
                                   backer: .template |> User.lens.name .~ "Swanson")

      self.backerNameAccessibilityLabel.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerNameAccessibilityLabel.assertValues(["Swanson"], "Name should be Swanson")
    }
  }

  func testBackerSequence() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template |> Backing.lens.sequence .~ 5)) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.vm.inputs.viewDidLoad()

      self.backerSequence.assertDidNotEmitValue()

      self.scheduler.advance()

      self.backerSequence.assertValues([Strings.backer_modal_backer_number(backer_number: "5")],
                                       "Backer label emits backer sequence")
    }
  }

  func testBackerSequenceAccessibilityLabel() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template |> Backing.lens.sequence .~ 5)) {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerSequenceAccessibilityLabel.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.backerSequence.assertDidNotEmitValue()

      self.scheduler.advance()

      self.backerSequenceAccessibilityLabel.assertValues([Strings.backer_modal_backer_number(backer_number:
        "5")],
                                       "Backer label emits backer sequence")
    }
  }

  func testBackerPledgeAmountAndDate() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.amount .~ 35
      |> Backing.lens.pledgedAt .~ 1468527587.32843 )) {

        self.vm.inputs.configureWith(project: .template |> Project.lens.country .~ .US, backer: nil)

        self.vm.inputs.viewDidLoad()

        self.backerPledgeAmountAndDate.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerPledgeAmountAndDate.assertValues(["$35 on July 14, 2016"],
                                                                    "Backer label emits pledge amount")
    }
  }

  func testBackerPledgeAmountAndDateAccessibilityLabel() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.amount .~ 35
      |> Backing.lens.pledgedAt .~ 1468527587.32843 )) {
        self.vm.inputs.configureWith(project: .template |> Project.lens.country .~ .US, backer: nil)

        self.backerPledgeAmountAndDateAccessibilityLabel.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerPledgeAmountAndDateAccessibilityLabel.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerPledgeAmountAndDateAccessibilityLabel.assertValues(["Pledged $35 on July 14, 2016"],
                                                    "Backer label emits pledge amount")
    }
  }

  func testBackerPledgeStatus() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.status .~ .pledged)) {
        self.vm.inputs.configureWith(project: .template, backer: nil)

        self.vm.inputs.viewDidLoad()

        self.backerPledgeStatus.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerPledgeStatus.assertValues(["Status: Pledged"], "Backer label emits pledge status")
    }
  }

  func testbackerPledgeStatusAccessibilityLabel() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.status .~ .pledged)) {
        self.vm.inputs.configureWith(project: .template, backer: nil)

        self.backerPledgeStatusAccessibilityLabel.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerPledgeStatusAccessibilityLabel.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerPledgeStatusAccessibilityLabel.assertValues(["Status: Pledged"],
                                                               "Backer label emits pledge status")
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

        self.backerRewardDescription.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerRewardDescription.assertValues(["$10 - Cool Item"],
                                                "Backer label emits reward description")
    }
  }

  func testBackerRewardDescriptionAccessibilityLabel() {
    let reward = .template |> Reward.lens.description .~ "Cool Item"

    withEnvironment(apiService: MockService (fetchBackingResponse: .template
      |> Backing.lens.amount .~ 10_00
      |> Backing.lens.reward .~ reward)) {
        self.vm.inputs.configureWith(project: .template, backer: nil)

        self.backerRewardDescriptionAccessibilityLabel.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerRewardDescriptionAccessibilityLabel.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerRewardDescriptionAccessibilityLabel.assertValues(["$10 - Cool Item"],
                                                                    "Backer label emits reward description")
    }
  }

  func testBackerShippingAmount() {
    withEnvironment(apiService: MockService (fetchBackingResponse: .template
      |> Backing.lens.shippingAmount .~ 37)) {
        self.vm.inputs.configureWith(project: .template, backer: nil)

        self.backerShippingAmount.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerShippingAmount.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerShippingAmount.assertValues(["$37"], "Backer label emits shipping amount")
    }
  }

  func testBackerShippingAmountAccessibilityLabel() {
    withEnvironment(apiService: MockService (fetchBackingResponse: .template
      |> Backing.lens.shippingAmount .~ 37)) {
        self.vm.inputs.configureWith(project: .template, backer: nil)

        self.backerShippingAmountAccessibilityLabel.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerShippingAmountAccessibilityLabel.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerShippingAmountAccessibilityLabel.assertValues(["$37"],
                                                               "Backer label emits shipping amount")
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

        self.backerShippingDescription.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerShippingDescription.assertValues([ "Ships only to Litville, Legitas"],
                                                    "Backer label emits reward description")
    }
  }

  func testBackerShippingDescriptionAccessibilityLabel() {
    let shipping = Reward.Shipping(
      enabled: true,
      preference: .none,
      summary: "Ships only to Litville, Legitas"
    )

    withEnvironment(apiService: MockService (fetchBackingResponse: .template
      |> Backing.lens.reward .~ (.template |> Reward.lens.shipping .~ shipping))) {
        self.vm.inputs.configureWith(project: .template, backer: nil)

        self.backerShippingDescriptionAccessibilityLabel.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerShippingDescriptionAccessibilityLabel.assertDidNotEmitValue()

        self.scheduler.advance()

        self.backerShippingDescriptionAccessibilityLabel.assertValues([ "Ships only to Litville, Legitas"],
                                                    "Backer label emits reward description")
    }
  }

  func testEstimatedDeliveryDateLabelText() {
    let date = 1485907200.0// Feb 01 2017 in UTC
    let EST = TimeZone(abbreviation: "EST")!
    var calEST = Calendar.current
    calEST.timeZone = EST

    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ date

    withEnvironment(apiService: MockService(fetchBackingResponse: .template
      |> Backing.lens.reward .~ reward), calendar: calEST ) {
        self.vm.inputs.configureWith(project: .template |> Project.lens.country .~ .US, backer: nil)

        self.backerPledgeAmountAndDateAccessibilityLabel.assertValues([])

        self.vm.inputs.viewDidLoad()

        self.backerPledgeAmountAndDateAccessibilityLabel.assertDidNotEmitValue()

        self.scheduler.advance()

        self.estimatedDeliveryDateLabelText.assertValues(["February 2017"],
                                                         "Emits the estimated delivery date")
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

      self.scheduler.advance()

      self.vm.inputs.viewMessagesTapped()

      self.goToMessagesProject.assertValues([project])
      self.goToMessagesBacking.assertValues([backing])
    }
  }

  func testGoToMessageCreator() {
    let project = Project.template
    let backing = Backing.template

    withEnvironment(apiService: MockService(fetchBackingResponse: backing)) {
      self.vm.inputs.configureWith(project: project, backer: nil)

      self.vm.inputs.viewDidLoad()

      self.goToMessageCreatorSubject.assertDidNotEmitValue()
      self.goToMessageCreatorContext.assertDidNotEmitValue()

      self.scheduler.advance()

      self.vm.inputs.messageCreatorTapped()

      self.goToMessageCreatorSubject.assertValues([.project(project)])
      self.goToMessageCreatorContext.assertValues([.backerModal])
    }
  }

  func testCurrentUserIsCreator() {
    let creator = .template |> User.lens.id .~ 42
    let project = .template
      |> Project.lens.creator .~ creator
    let backing = Backing.template

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: creator) {
      self.vm.inputs.configureWith(project: project, backer: nil)

      self.vm.inputs.viewDidLoad()

      self.hideActionsStackView.assertValues([false], "Shows actions stack view")
    }
  }

  func testCurrentUserIsBacker() {
    let project = Project.template
    let backer = .template |> User.lens.id .~ 20
    let backing = Backing.template

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: backer) {
      self.vm.inputs.configureWith(project: project, backer: backer)

      self.vm.inputs.viewDidLoad()

      self.hideActionsStackView.assertValues([false], "Shows actions stack view")
    }
  }

  func testCurrentUserIsCollaborator() {
    let creator = .template |> User.lens.id .~ 42
    let project = .template
      |> Project.lens.creator .~ creator
    let backing = Backing.template
    let backer = .template |> User.lens.id .~ 199
    let collaborator = .template |> User.lens.id .~ 99

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: collaborator) {
      self.vm.inputs.configureWith(project: project, backer: backer)

      self.vm.inputs.viewDidLoad()

      self.hideActionsStackView.assertValues([true], "Hides actions stack view for non-creator/non-backer")
    }
  }

  func testEventsTracked() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template)) {
      self.vm.inputs.configureWith(project: .template, backer: .template)

      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertEqual(["Viewed Pledge Info", "Modal Dialog View"],
                     self.trackingClient.events, "Koala pledge view tracked")

      XCTAssertEqual([nil, true],
                     self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    }
  }

  func testRootStackViewAxis() {
    let project = Project.template
    let backer = .template |> User.lens.id .~ 20

    withEnvironment(currentUser: backer, language: .de) {
      self.vm.inputs.configureWith(project: project, backer: backer)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rootStackViewAxis.assertValues([UILayoutConstraintAxis.vertical])
    }
  }

  func testLoadingOverlay() {
    withEnvironment(apiService: MockService(fetchBackingResponse: .template)) {
      self.vm.inputs.configureWith(project: .template, backer: .template)
      self.vm.inputs.viewDidLoad()

      self.loadingOverlayIsHidden.assertValues([false])

      self.scheduler.advance()

      self.loadingOverlayIsHidden.assertValues([false, true])
    }
  }
}
