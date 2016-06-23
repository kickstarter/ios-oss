import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
import Prelude
import Result

internal final class ProjectActivityLaunchCellViewModelTests: TestCase {
  private let vm: ProjectActivityLaunchCellViewModelType = ProjectActivityLaunchCellViewModel()

  private let backgroundImage = TestObserver<String?, NoError>()
  private let defaultUser = .template |> User.lens.name .~ "Christopher"
  private let goal = TestObserver<String, NoError>()
  private let launchDate = TestObserver<String, NoError>()
  private let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundImageURL.map { $0?.absoluteString }.observe(self.backgroundImage.observer)
    self.vm.outputs.goal.observe(self.goal.observer)
    self.vm.outputs.launchDate.observe(self.launchDate.observer)
    self.vm.outputs.title.observe(self.title.observer)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: self.defaultUser))
  }

  func testBackgroundImage() {
    let project = .template
      |> Project.lens.photo.med .~ "http://coolpic.com/cool.jpg"
    let activity = .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)
    self.backgroundImage.assertValues(["http://coolpic.com/cool.jpg"], "Emits project's image URL")
  }

  func testGoal() {
    let country = Project.Country.US
    let goal = 5000
    let project = .template
      |> Project.lens.country .~ country
      |> Project.lens.stats.goal .~ goal
    let activity = .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    self.goal.assertValues([Format.currency(goal, country: country)], "Emits project goal")
  }

  func testLaunchDate() {
    let launchedAt = NSDate().timeIntervalSince1970
    let project = .template
      |> Project.lens.dates.launchedAt .~ launchedAt
    let activity = .template
      |> Activity.lens.project .~ project
    let launchDate = Format.date(secondsInUTC: launchedAt, dateStyle: .MediumStyle, timeStyle: .NoStyle)

    self.vm.inputs.configureWith(activity: activity)

    self.launchDate.assertValues([launchDate], "Emits project's launch date")
  }

  func testTitleWhenCreatorIsNotCurrentUser() {
    let creatorName = "Blobby"
    let projectName = "Sick Skull Graphic Watch"
    let creator = .template
      |> User.lens.id .~ 50
      |> User.lens.name .~ creatorName
    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.creator .~ creator
    let activity = .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    let expected = Strings.activity_project_state_change_creator_launched_a_project(
      creator_name: creatorName, project_name: projectName
    )
    self.title.assertValues([expected], "Emits creator and project name")
  }

  func testTitleWhenCreatorIsCurrentUser() {
    let projectName = "Sick Skull Graphic Watch"
    let project = .template
      |> Project.lens.name .~ projectName
      |> Project.lens.creator .~ self.defaultUser
    let activity = .template
      |> Activity.lens.project .~ project

    self.vm.inputs.configureWith(activity: activity)

    let expected = Strings.activity_project_state_change_creator_launched_a_project(
      creator_name: Strings.activity_creator_you(), project_name: projectName
    )
    self.title.assertValues([expected], "Emits 'You' as author, and project name")
  }
}
