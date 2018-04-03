// swiftlint:disable force_unwrapping
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class BackingViewModelTests: TestCase {
  private let vm: BackingViewModelType = BackingViewModel()

  private let backerAvatarURL = TestObserver<String?, NoError>()
  private let backerName = TestObserver<String, NoError>()
  private let backerSequence = TestObserver<String, NoError>()
  private let goToMessageCreatorSubject = TestObserver<MessageSubject, NoError>()
  private let goToMessageCreatorContext = TestObserver<Koala.MessageDialogContext, NoError>()
  private let goToMessagesBacking = TestObserver<Backing, NoError>()
  private let goToMessagesProject = TestObserver<Project, NoError>()
  private let loaderIsAnimating = TestObserver<Bool, NoError>()
  private let markAsReceivedSectionIsHidden = TestObserver<Bool, NoError>()
  private let messageButtonTitleText = TestObserver<String, NoError>()
  private let opacityForContainers = TestObserver<CGFloat, NoError>()
  private let pledgeAmount = TestObserver<String, NoError>()
  private let pledgeSectionTitle = TestObserver<String, NoError>()
  private let rewardDescription = TestObserver<String, NoError>()
  private let rewardMarkedReceived = TestObserver<Bool, NoError>()
  private let rewardSectionAndShippingIsHidden = TestObserver<Bool, NoError>()
  private let rewardSectionTitle = TestObserver<String, NoError>()
  private let rewardTitleWithAmount = TestObserver<String, NoError>()
  private let rootStackViewAxis = TestObserver<UILayoutConstraintAxis, NoError>()
  private let shippingAmount = TestObserver<String, NoError>()
  private let statusDescription = TestObserver<String, NoError>()
  private let totalPledgeAmount = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "hello", user: .template))
    self.vm.outputs.backerAvatarURL.map { $0?.absoluteString }.observe(backerAvatarURL.observer)
    self.vm.outputs.backerName.observe(backerName.observer)
    self.vm.outputs.backerSequence.observe(backerSequence.observer)
    self.vm.outputs.goToMessageCreator.map(first).observe(goToMessageCreatorSubject.observer)
    self.vm.outputs.goToMessageCreator.map(second).observe(goToMessageCreatorContext.observer)
    self.vm.outputs.goToMessages.map(first).observe(goToMessagesProject.observer)
    self.vm.outputs.goToMessages.map(second).observe(goToMessagesBacking.observer)
    self.vm.outputs.loaderIsAnimating.observe(loaderIsAnimating.observer)
    self.vm.outputs.markAsReceivedSectionIsHidden.observe(markAsReceivedSectionIsHidden.observer)
    self.vm.outputs.messageButtonTitleText.observe(messageButtonTitleText.observer)
    self.vm.outputs.opacityForContainers.observe(opacityForContainers.observer)
    self.vm.outputs.pledgeAmount.observe(pledgeAmount.observer)
    self.vm.outputs.pledgeSectionTitle.map { $0.string }.observe(pledgeSectionTitle.observer)
    self.vm.outputs.rewardDescription.observe(rewardDescription.observer)
    self.vm.outputs.rewardMarkedReceived.observe(rewardMarkedReceived.observer)
    self.vm.outputs.rewardSectionAndShippingIsHidden.observe(rewardSectionAndShippingIsHidden.observer)
    self.vm.outputs.rewardSectionTitle.map { $0.string }.observe(rewardSectionTitle.observer)
    self.vm.outputs.rewardTitleWithAmount.observe(rewardTitleWithAmount.observer)
    self.vm.outputs.rootStackViewAxis.observe(rootStackViewAxis.observer)
    self.vm.outputs.shippingAmount.observe(shippingAmount.observer)
    self.vm.outputs.statusDescription.map { $0.string }.observe(statusDescription.observer)
    self.vm.outputs.totalPledgeAmount.observe(totalPledgeAmount.observer)
  }

  func testHeaderBackerInfo() {
    let user = .template
      |> User.lens.name .~ "Stella"
      |> User.lens.avatar.small .~ "http://www.image.com/lit.jpg"

    let backing = .template
      |> Backing.lens.sequence .~ 5
      |> Backing.lens.backer .~ user

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: user) {
      self.vm.inputs.configureWith(project: .template, backer: user)

      self.backerAvatarURL.assertValueCount(0)
      self.backerName.assertValueCount(0)
      self.backerSequence.assertValueCount(0)
      self.loaderIsAnimating.assertValueCount(0)
      self.opacityForContainers.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.backerAvatarURL.assertValues(["http://www.image.com/lit.jpg"], "Emits user avatar url.")
      self.backerName.assertValues(["Stella"], "Emits backer name.")
      self.backerSequence
        .assertValues([Strings.backer_modal_backer_number(backer_number: Format.wholeNumber(0))])
      self.loaderIsAnimating.assertValues([true])
      self.opacityForContainers.assertValues([0.0], "Containers below header start at 0 opacity.")

      self.scheduler.advance()

      self.backerAvatarURL.assertValues(["http://www.image.com/lit.jpg"], "User avatar does not emit again.")
      self.backerName.assertValues(["Stella"], "Backer name does not emit again.")
      self.backerSequence
        .assertValues([Strings.backer_modal_backer_number(backer_number: Format.wholeNumber(0)),
                       Strings.backer_modal_backer_number(backer_number: "5")], "Emits backer sequence.")
      self.loaderIsAnimating.assertValues([true, false])
      self.opacityForContainers.assertValues([0.0, 1.0], "Containers fade in after full backer info loads.")
    }
  }

  func testBackerIsNil() {
    withEnvironment(currentUser: .template |> User.lens.name .~ "Carla") {
      self.vm.inputs.configureWith(project: .template, backer: nil)

      self.backerName.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.backerName.assertValues(["Carla"], "Name should be Carla")
    }
  }

  func testPledgeInfo_BackerView() {
    let user = .template
      |> User.lens.name .~ "Stella"

    let backing = .template
      |> Backing.lens.amount .~ 35
      |> Backing.lens.backer .~ user
      |> Backing.lens.pledgedAt .~ 1468527587.32843
      |> Backing.lens.shippingAmount .~ 5
      |> Backing.lens.status .~ .pledged

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: user) {
      self.vm.inputs.configureWith(project: .template, backer: user)

      self.pledgeAmount.assertValueCount(0)
      self.pledgeSectionTitle.assertValueCount(0)
      self.shippingAmount.assertValueCount(0)
      self.statusDescription.assertValueCount(0)
      self.totalPledgeAmount.assertValueCount(0)
      self.messageButtonTitleText.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.pledgeAmount.assertValues([""])
      self.pledgeSectionTitle.assertValues([""])
      self.shippingAmount.assertValues([""])
      self.statusDescription.assertValues([""])
      self.totalPledgeAmount.assertValues([""])

      self.scheduler.advance()

      self.pledgeAmount.assertValues(["", "$30"])
      self.pledgeSectionTitle.assertValues(["", "You pledged on July 14, 2016"])
      self.shippingAmount.assertValues(["", "$5"])
      self.statusDescription.assertValues(["", Strings.Youve_pledged_to_support_this_project()])
      self.totalPledgeAmount.assertValues(["", "$35"])
      self.messageButtonTitleText.assertValues([Strings.Contact_creator()])
    }
  }

  func testPledgeInfo_CreatorView() {
    let creator = .template
      |> User.lens.id .~ 12

    let backing = .template
      |> Backing.lens.pledgedAt .~ 1468527587.32843
      |> Backing.lens.status .~ .pledged

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: creator) {
      self.vm.inputs.configureWith(project: .template, backer: .template)

      self.pledgeSectionTitle.assertValueCount(0)
      self.statusDescription.assertValueCount(0)
      self.messageButtonTitleText.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.pledgeSectionTitle.assertValues([""])
      self.statusDescription.assertValues([""])

      self.scheduler.advance()

      self.pledgeSectionTitle.assertValues(["", "Pledged on July 14, 2016"])
      self.statusDescription.assertValues(["", Strings.Backer_has_pledged_to_this_project()])
      self.messageButtonTitleText.assertValues([localizedString(key: "Contact_backer",
                                                                defaultValue: "Contact backer")])
    }
  }

  func testRewardInfo_BackerView() {
    let date = 1485907200.0 // Feb 01 2017 in UTC
    let EST = TimeZone(abbreviation: "EST")!
    var calEST = Calendar.current
    calEST.timeZone = EST

    let reward = .template
      |> Reward.lens.title .~ "A Nice Title"
      |> Reward.lens.description .~ "A nice description."
      |> Reward.lens.estimatedDeliveryOn .~ date

    let backing = .template
      |> Backing.lens.amount .~ 10_00
      |> Backing.lens.reward .~ reward

    withEnvironment(apiService: MockService(fetchBackingResponse: backing),
                    calendar: calEST,
                    currentUser: .template) {

      self.vm.inputs.configureWith(project: .template, backer: .template)

      self.rewardDescription.assertValueCount(0)
      self.rewardSectionAndShippingIsHidden.assertValueCount(0)
      self.rewardSectionTitle.assertValueCount(0)
      self.rewardTitleWithAmount.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.rewardDescription.assertValues([""])
      self.rewardSectionAndShippingIsHidden.assertValues([])
      self.rewardSectionTitle.assertValues([""])
      self.rewardTitleWithAmount.assertValues([""])

      self.scheduler.advance()

      self.rewardDescription.assertValues(["", "A nice description."])
      self.rewardSectionAndShippingIsHidden.assertValues([false], "Reward and shipping are not hidden.")
      self.rewardSectionTitle.assertValues(["", "Your reward estimated for delivery in Feb 2017"])
      self.rewardTitleWithAmount.assertValues(["", "$10 - A Nice Title"])
    }
  }

  func testRewardInfo_CreatorView() {
    let date = 1485907200.0 // Feb 01 2017 in UTC
    let EST = TimeZone(abbreviation: "EST")!
    var calEST = Calendar.current
    calEST.timeZone = EST

    let creator = .template
      |> User.lens.id .~ 12

    let reward = .template
      |> Reward.lens.estimatedDeliveryOn .~ date

    let backing = .template
      |> Backing.lens.reward .~ reward

    withEnvironment(apiService: MockService(fetchBackingResponse: backing),
                    calendar: calEST,
                    currentUser: creator) {

                      self.vm.inputs.configureWith(project: .template, backer: .template)

                      self.rewardSectionTitle.assertValueCount(0)

                      self.vm.inputs.viewDidLoad()

                      self.rewardSectionTitle.assertValues([""])

                      self.scheduler.advance()

                      self.rewardSectionTitle.assertValues(["", "Reward estimated for delivery in Feb 2017"])
    }
  }

  func testRewardAndShippingHidden() {
    let reward = .template
      |> Reward.lens.id .~ Reward.noReward.id

    let backing = .template
      |> Backing.lens.reward .~ reward

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, backer: .template)

      self.rewardSectionAndShippingIsHidden.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardSectionAndShippingIsHidden.assertValues([true])
    }
  }

  func testMarkReceivedSection_Hidden() {
    let reward = .template
      |> Reward.lens.id .~ Reward.noReward.id

    let backing = .template
      |> Backing.lens.reward .~ reward

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, backer: .template)

      self.markAsReceivedSectionIsHidden.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.markAsReceivedSectionIsHidden.assertValues([])

      self.scheduler.advance()

      self.markAsReceivedSectionIsHidden.assertValues([true])
    }
  }

  func testMarkReceivedSection_NotHidden() {
    let backing = .template
      |> Backing.lens.status .~ .collected

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, backer: .template)

      self.markAsReceivedSectionIsHidden.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.markAsReceivedSectionIsHidden.assertValues([])

      self.scheduler.advance()

      self.markAsReceivedSectionIsHidden.assertValues([false])
    }
  }

  func testMarkReceivedSectionNotHidden_UserIsCollaboratorAndBacker() {
    let backer = .template |> User.lens.id .~ 20

    let backing = .template
      |> Backing.lens.status .~ .collected

    let project = .template
      |> Project.lens.memberData.permissions .~ [.editProject, .editFaq, .post, .comment, .viewPledges,
    .fulfillment]

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: backer) {
      self.vm.inputs.configureWith(project: project, backer: backer)

      self.markAsReceivedSectionIsHidden.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.markAsReceivedSectionIsHidden.assertValues([])

      self.scheduler.advance()

      self.markAsReceivedSectionIsHidden.assertValues([false])
    }
  }

  func testMarkReceivedSectionHidden_UserIsCollaborator() {
    let collaborator = .template |> User.lens.id .~ 20
    let backer = .template |> User.lens.id .~ 10
    let backing = .template
      |> Backing.lens.backer .~ backer

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: collaborator) {
      self.vm.inputs.configureWith(project: .template, backer: backer)

      self.markAsReceivedSectionIsHidden.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.markAsReceivedSectionIsHidden.assertValues([])

      self.scheduler.advance()

      self.markAsReceivedSectionIsHidden.assertValues([true])
    }
  }

  func testRewardMarkedReceived() {
    let backer = .template |> User.lens.id .~ 20
    let backing = Backing.template

    withEnvironment(apiService: MockService(fetchBackingResponse: backing), currentUser: backer) {
      self.vm.inputs.configureWith(project: .template, backer: backer)
      self.vm.inputs.viewDidLoad()

      self.rewardMarkedReceived.assertValues([])

      self.scheduler.advance()

      self.rewardMarkedReceived.assertValues([true])

      let newBacking = .template
        |> Backing.lens.backerCompleted .~ false

      withEnvironment(apiService: MockService(fetchBackingResponse: newBacking) ) {
        self.vm.inputs.rewardReceivedTapped(on: false)

        self.scheduler.advance()

        self.rewardMarkedReceived.assertValues([true, false])
      }
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
}
