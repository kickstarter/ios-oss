import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardActionCellViewModelTests: TestCase {
  private let vm = DashboardActionCellViewModel()

  private let activityButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let activityRowHidden = TestObserver<Bool, NoError>()
  private let goToActivity = TestObserver<Project, NoError>()
  private let goToMessages = TestObserver<Project, NoError>()
  private let goToPostUpdate = TestObserver<Project, NoError>()
  private let lastUpdatePublishedAt = TestObserver<String, NoError>()
  private let lastUpdatePublishedLabelHidden = TestObserver<Bool, NoError>()
  private let messagesButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let messagesRowHidden = TestObserver<Bool, NoError>()
  private let postUpdateButtonAccessibilityValue = TestObserver<String, NoError>()
  private let postUpdateButtonHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.activityButtonAccessibilityLabel.observe(self.activityButtonAccessibilityLabel.observer)
    self.vm.outputs.activityRowHidden.observe(self.activityRowHidden.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToMessages.observe(self.goToMessages.observer)
    self.vm.outputs.goToPostUpdate.observe(self.goToPostUpdate.observer)
    self.vm.outputs.lastUpdatePublishedAt.observe(self.lastUpdatePublishedAt.observer)
    self.vm.outputs.lastUpdatePublishedLabelHidden.observe(self.lastUpdatePublishedLabelHidden.observer)
    self.vm.outputs.messagesButtonAccessibilityLabel.observe(self.messagesButtonAccessibilityLabel.observer)
    self.vm.outputs.messagesRowHidden.observe(self.messagesRowHidden.observer)
    self.vm.outputs.postUpdateButtonAccessibilityValue
      .observe(self.postUpdateButtonAccessibilityValue.observer)
    self.vm.outputs.postUpdateButtonHidden.observe(self.postUpdateButtonHidden.observer)
  }

  func testAccessibilityElements() {
    let date = NSDate().timeIntervalSince1970
    let formattedDate = Format.date(secondsInUTC: date, timeStyle: .NoStyle)
    let project = .template
      |> Project.lens.memberData.lastUpdatePublishedAt .~ date
      |> Project.lens.memberData.unreadMessagesCount .~ 10
      |> Project.lens.memberData.unseenActivityCount .~ 7

    self.vm.inputs.configureWith(project: project)

    self.activityButtonAccessibilityLabel.assertValues(["Activity, 7 unseen"])
    self.messagesButtonAccessibilityLabel.assertValues(["Messages, 10 unread"])
    self.postUpdateButtonAccessibilityValue.assertValues(["Last updated on \(formattedDate)."])
  }

  func testActivityRowHidden_WithViewPledgePermissions() {
    self.vm.inputs.configureWith(
      project: .template |> Project.lens.memberData.permissions .~ [.viewPledges]
    )

    self.activityRowHidden.assertValues([false])
  }

  func testActivityRowHidden_WithoutViewPledgePermissions() {
    self.vm.inputs.configureWith(
      project: .template |> Project.lens.memberData.permissions .~ []
    )

    self.activityRowHidden.assertValues([true])
  }

  func testGoToScreens() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)

    self.vm.inputs.activityTapped()
    self.goToActivity.assertValues([project], "Go to activity screen.")

    self.vm.inputs.messagesTapped()
    self.goToMessages.assertValues([project], "Go to messages screen.")

    self.vm.inputs.postUpdateTapped()
    self.goToPostUpdate.assertValues([project], "Go to post update screen.")
  }

  func testLastUpdatePublishedAtEmits() {
    let date = NSDate().timeIntervalSince1970
    let formattedDate = Format.date(secondsInUTC: date, timeStyle: .NoStyle)
    let project = .template
      |> Project.lens.memberData.lastUpdatePublishedAt .~ date

    self.vm.inputs.configureWith(project: project)
    self.lastUpdatePublishedAt.assertValues(["Last updated on \(formattedDate)."])
  }

  func testPermissionsWithCreator() {
    let creator = .template |> User.lens.id .~ 42
    let project = .template
      |> Project.lens.creator .~ creator
      |> Project.lens.memberData.permissions .~ [.post]

    withEnvironment(currentUser: creator) {
      self.vm.inputs.configureWith(project: project)

      self.lastUpdatePublishedLabelHidden.assertValues([false], "Last update label is not hidden.")
      self.messagesRowHidden.assertValues([false], "Messages row is not hidden.")
      self.postUpdateButtonHidden.assertValues([false], "Post update button is not hidden.")
    }
  }

  func testPermissionsWithCollaborator() {
    let creator = .template |> User.lens.id .~ 42
    let collaborator = .template |> User.lens.id .~ 99
    let project = .template
      |> Project.lens.creator .~ creator
      |> Project.lens.memberData.permissions .~ [.post]

    withEnvironment(currentUser: collaborator) {
      self.vm.inputs.configureWith(project: project)

      self.lastUpdatePublishedLabelHidden.assertValues([false], "Last update label is not hidden.")
      self.messagesRowHidden.assertValues([true], "Messages row is hidden for non-creator.")
      self.postUpdateButtonHidden.assertValues([false], "Post update button is not hidden.")
    }
  }

  func testPermissionsWithCollaboratorWithoutPostPermission() {
    let creator = .template |> User.lens.id .~ 42
    let collaborator = .template |> User.lens.id .~ 99
    let project = .template
      |> Project.lens.creator .~ creator
      |> Project.lens.memberData.permissions .~ []

    withEnvironment(currentUser: collaborator) {
      self.vm.inputs.configureWith(project: project)

      self.lastUpdatePublishedLabelHidden
        .assertValues([true], "Last update label is hidden without post permissions.")
      self.messagesRowHidden.assertValues([true], "Messages row is hidden for non-creator.")
      self.postUpdateButtonHidden.assertValues([true],
                                               "Post update button is hidden without post permissions.")
    }
  }
}
