import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardActionCellViewModelTests: TestCase {
  fileprivate let vm = DashboardActionCellViewModel()

  fileprivate let activityButtonAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let activityRowHidden = TestObserver<Bool, NoError>()
  fileprivate let goToActivity = TestObserver<Project, NoError>()
  fileprivate let goToMessages = TestObserver<Project, NoError>()
  fileprivate let goToPostUpdate = TestObserver<Project, NoError>()
  fileprivate let lastUpdatePublishedAt = TestObserver<String, NoError>()
  fileprivate let lastUpdatePublishedLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let messagesButtonAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let messagesRowHidden = TestObserver<Bool, NoError>()
  fileprivate let postUpdateButtonAccessibilityValue = TestObserver<String, NoError>()
  fileprivate let postUpdateButtonHidden = TestObserver<Bool, NoError>()

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
    let date = Date().timeIntervalSince1970
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
    let date = Date().timeIntervalSince1970
    let formattedDate = Format.date(secondsInUTC: date, timeStyle: .NoStyle)
    let project = .template
      |> Project.lens.memberData.lastUpdatePublishedAt .~ date

    self.vm.inputs.configureWith(project: project)
    self.lastUpdatePublishedAt.assertValues(["Last updated on \(formattedDate)."])
  }

  func testLastUpdatePublishedAtEmits_CollaboratorNoUpdates() {
    let collaborator = .template
      |> User.lens.id .~ 9
    let project = Project.template

    withEnvironment(currentUser: collaborator) {
      vm.inputs.configureWith(project: project)

      self.lastUpdatePublishedAt.assertValues(["No one has posted an update yet."])
    }
  }

  func testLastUpdatePublishedAtEmits_CreatorNoUpdates() {
    let creator = .template |> User.lens.id .~ 42
    let project = .template |> Project.lens.creator .~ creator

    withEnvironment(currentUser: creator) {
      vm.inputs.configureWith(project: project)

      self.lastUpdatePublishedAt.assertValues(
        [Strings.dashboard_post_update_button_subtitle_you_have_not_posted_an_update_yet()]
      )
    }
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
