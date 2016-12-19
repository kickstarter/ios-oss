import Prelude
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class ActivityProjectStatusViewModelTests: TestCase {
  fileprivate let vm: ActivityProjectStatusViewModelType = ActivityProjectStatusViewModel()
  fileprivate let metadataText = TestObserver<String, NoError>()
  fileprivate let percentFundedText = TestObserver<String, NoError>()
  fileprivate let projectImageURL = TestObserver<String?, NoError>()
  fileprivate let projectName = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.metadataText.observe(self.metadataText.observer)
    self.vm.outputs.percentFundedText.map { $0.string }.observe(self.percentFundedText.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImageURL.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
  }

  func testProject_Launched() {
    let project = .cosmicSurgery
      |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
      |> Project.lens.stats.fundingProgress .~ 0

    let activity = .template
      |> Activity.lens.id .~ 0
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .launch

    self.vm.inputs.configureWith(activity: activity)

    self.metadataText.assertValues(
      [Strings.Friend_name_launched_a_project(friend_name: project.creator.name)]
    )
    self.percentFundedText.assertValues(["0% funded"])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectName.assertValues([project.name])
  }

  func testProject_You_Launched() {
    let you = .template
      |> User.lens.id .~ 4
      |> User.lens.name .~ "Gina B"

    let project = .cosmicSurgery
      |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
      |> Project.lens.stats.fundingProgress .~ 0.01
      |> Project.lens.creator .~ you

    let activity = .template
      |> Activity.lens.id .~ 0
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .launch

    withEnvironment(currentUser: you) {
      self.vm.inputs.configureWith(activity: activity)

      self.metadataText.assertValues([Strings.You_Launched()])
      self.percentFundedText.assertValues(["1% funded"])
      self.projectImageURL.assertValues([project.photo.full])
      self.projectName.assertValues([project.name])
    }
  }

  func testProject_Success() {
    let you = .template
      |> User.lens.id .~ 4
      |> User.lens.name .~ "Gina B"

    let project = .cosmicSurgery
      |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
      |> Project.lens.stats.fundingProgress .~ 1.3
      |> Project.lens.creator .~ you

    let activity = .template
      |> Activity.lens.id .~ 0
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .success

    self.vm.inputs.configureWith(activity: activity)

    self.metadataText.assertValues([Strings.activity_successfully_funded()])
    self.percentFundedText.assertValues(["129% funded"])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectName.assertValues([project.name])
  }

  func testProject_Failure() {
    let project = .cosmicSurgery
      |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
      |> Project.lens.stats.fundingProgress .~ 0.6

    let activity = .template
      |> Activity.lens.id .~ 0
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .failure

    self.vm.inputs.configureWith(activity: activity)

    self.metadataText.assertValues([Strings.Unsuccessfully_Funded()])
    self.percentFundedText.assertValues(["60% funded"])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectName.assertValues([project.name])
  }

  func testProject_Canceled() {
    let project = .cosmicSurgery
      |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
      |> Project.lens.stats.fundingProgress .~ 0.01

    let activity = .template
      |> Activity.lens.id .~ 0
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .cancellation

    self.vm.inputs.configureWith(activity: activity)

    self.metadataText.assertValues([Strings.Project_Cancelled()])
    self.percentFundedText.assertValues(["1% funded"])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectName.assertValues([project.name])
  }

  func testProject_Suspended() {
    let project = .cosmicSurgery
      |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
      |> Project.lens.stats.fundingProgress .~ 0.04

    let activity = .template
      |> Activity.lens.id .~ 0
      |> Activity.lens.project .~ project
      |> Activity.lens.category .~ .suspension

    self.vm.inputs.configureWith(activity: activity)

    self.metadataText.assertValues([Strings.Project_Suspended()])
    self.percentFundedText.assertValues(["4% funded"])
    self.projectImageURL.assertValues([project.photo.full])
    self.projectName.assertValues([project.name])
  }
}
