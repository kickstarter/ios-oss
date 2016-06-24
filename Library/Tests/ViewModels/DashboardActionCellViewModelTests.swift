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
  private let goToActivity = TestObserver<Project, NoError>()
  private let goToMessages = TestObserver<Project, NoError>()
  private let goToPostUpdate = TestObserver<Project, NoError>()
  private let lastUpdatePublishedAt = TestObserver<String, NoError>()
  private let lastUpdatePublishedLabelHidden = TestObserver<Bool, NoError>()
  private let messagesRowHidden = TestObserver<Bool, NoError>()
  private let postUpdateButtonHidden = TestObserver<Bool, NoError>()
  private let showShareSheet = TestObserver<Project, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
    self.vm.outputs.goToMessages.observe(self.goToMessages.observer)
    self.vm.outputs.goToPostUpdate.observe(self.goToPostUpdate.observer)
    self.vm.outputs.lastUpdatePublishedAt.observe(self.lastUpdatePublishedAt.observer)
    self.vm.outputs.lastUpdatePublishedLabelHidden.observe(self.lastUpdatePublishedLabelHidden.observer)
    self.vm.outputs.messagesRowHidden.observe(self.messagesRowHidden.observer)
    self.vm.outputs.postUpdateButtonHidden.observe(self.postUpdateButtonHidden.observer)
    self.vm.outputs.showShareSheet.observe(self.showShareSheet.observer)
  }

  func testGoToScreens() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)

    self.vm.inputs.activityTapped()
    self.goToActivity.assertValues([project], "Go to activity screen.")

    self.vm.inputs.messagesTapped()
    self.goToMessages.assertValues([project], "Go to messages screen.")

    self.vm.inputs.shareTapped()
    self.showShareSheet.assertValues([project], "Show share sheet.")

    self.vm.inputs.postUpdateTapped()
    self.goToPostUpdate.assertValues([project], "Go to post update screen.")
  }

  func testLastUpdatePublishedAtEmits() {
    let date = NSDate().timeIntervalSince1970
    let formattedDate = Format.date(secondsInUTC: date, timeStyle: .NoStyle)
    let project = Project.template
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
