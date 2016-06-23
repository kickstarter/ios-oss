import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ProjectActivitySuccessViewModelTests: TestCase {
  private let vm: ProjectActivitySuccessCellViewModelType = ProjectActivitySuccessCellViewModel()

  private let backgroundImage = TestObserver<String?, NoError>()
  private let fundedDate = TestObserver<String, NoError>()
  private let goal = TestObserver<String, NoError>()
  private let pledged = TestObserver<String, NoError>()
  private let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundImageURL.map { $0?.absoluteString }.observe(self.backgroundImage.observer)
    self.vm.outputs.fundedDate.observe(self.fundedDate.observer)
    self.vm.outputs.goal.observe(self.goal.observer)
    self.vm.outputs.pledged.observe(self.pledged.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
  }

  func testBackgroundImage() {
    let project = .template
      |> Project.lens.photo.med .~ "http://coolpic.com/cool.jpg"
      |> Project.lens.state .~ .successful
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)
    self.backgroundImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits project's image URL")
  }

  func testFundedDate() {
    let deadline = NSDate().timeIntervalSince1970
    let project = .template
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project
    let deadlineDate = Format.date(secondsInUTC: deadline, dateStyle: .MediumStyle, timeStyle: .NoStyle)

    self.vm.inputs.configureWith(activity: activity)

    self.fundedDate.assertValues([deadlineDate], "Emits project's deadline")
  }

  func testGoal() {
    let country = Project.Country.US
    let goal = 5000
    let project = .template
      |> Project.lens.country .~ country
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.goal .~ goal
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.goal.assertValues([Format.currency(goal, country: country)], "Emits project goal")
  }

  func testPledged() {
    let country = Project.Country.US
    let pledged = 5000
    let project = .template
      |> Project.lens.country .~ country
      |> Project.lens.state .~ .successful
      |> Project.lens.stats.pledged .~ pledged
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.pledged.assertValues([Format.currency(pledged, country: country)], "Emits amount pledged to project")
  }

  func testTitle() {
    let projectName = "Sick Skull Graphic Wallet"
    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.state .~ .successful
    let activity = .template
      |> Activity.lens.category .~ .success
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    let expected = Strings
      .activity_project_state_change_project_was_successfully_funded(project_name: projectName)
    self.title.assertValues([expected], "Emits title indicating the project was successfully funded")
  }
}
