import Prelude
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class MostPopularSearchProjectCellViewModelTests: TestCase {
  private let vm: MostPopularSearchProjectCellViewModelType = MostPopularSearchProjectCellViewModel()

  private let metadataText = TestObserver<String, NoError>()
  private let percentFundedText = TestObserver<String, NoError>()
  private let progress = TestObserver<Float, NoError>()
  private let progressBarColor = TestObserver<UIColor, NoError>()
  private let projectImageUrl = TestObserver<String, NoError>()
  private let projectName = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.metadataText.observe(self.metadataText.observer)
    self.vm.outputs.percentFundedText.map { $0.string }.observe(self.percentFundedText.observer)
    self.vm.outputs.progress.observe(self.progress.observer)
    self.vm.outputs.progressBarColor.observe(self.progressBarColor.observer)
    self.vm.outputs.projectImageUrl.map { $0?.absoluteString ?? "" }.observe(self.projectImageUrl.observer)
    self.vm.outputs.projectName.map { $0.string }.observe(self.projectName.observer)
  }

  func testProjectData_Live() {
    let project = .cosmicSurgery
      |> Project.lens.stats.fundingProgress .~ 0.5
      |> Project.lens.state .~ .live
      |> Project.lens.photo.full .~ "http://wwww.cosmicsurgery.com/theproject.jpg"

    self.vm.inputs.configureWith(project: project)

    self.metadataText.assertValues(["15 days"])
    self.percentFundedText.assertValues(["50%"])
    self.progress.assertValues([0.5])
    self.progressBarColor.assertValues([UIColor.ksr_green_500])
    self.projectImageUrl.assertValues(["http://wwww.cosmicsurgery.com/theproject.jpg"])
    self.projectName.assertValues(["Cosmic Surgery"])
  }

  func testProjectData_Successful() {
    let project = .cosmicSurgery
      |> Project.lens.stats.fundingProgress .~ 2.25
      |> Project.lens.state .~ .successful
      |> Project.lens.photo.full .~ "http://wwww.cosmicsurgery.com/theproject.jpg"

    self.vm.inputs.configureWith(project: project)

    self.metadataText.assertValues(["Successful"])
    self.percentFundedText.assertValues(["225%"])
    self.progress.assertValues([2.25])
    self.progressBarColor.assertValues([UIColor.ksr_green_500])
    self.projectImageUrl.assertValues(["http://wwww.cosmicsurgery.com/theproject.jpg"])
    self.projectName.assertValues(["Cosmic Surgery"])
  }

  func testProjectData_Failure() {
    let project = .cosmicSurgery
      |> Project.lens.stats.fundingProgress .~ 0.25
      |> Project.lens.state .~ .failed
      |> Project.lens.photo.full .~ "http://wwww.cosmicsurgery.com/theproject.jpg"

    self.vm.inputs.configureWith(project: project)

    self.metadataText.assertValues(["Unsuccessful"])
    self.percentFundedText.assertValues(["25%"])
    self.progress.assertValues([0.25])
    self.progressBarColor.assertValues([UIColor.ksr_dark_grey_400])
    self.projectImageUrl.assertValues(["http://wwww.cosmicsurgery.com/theproject.jpg"])
    self.projectName.assertValues(["Cosmic Surgery"])
  }

  func testProjectData_Canceled() {
    let project = .cosmicSurgery
      |> Project.lens.stats.fundingProgress .~ 0.15
      |> Project.lens.state .~ .canceled
      |> Project.lens.photo.full .~ "http://wwww.cosmicsurgery.com/theproject.jpg"

    self.vm.inputs.configureWith(project: project)

    self.metadataText.assertValues(["Canceled"])
    self.percentFundedText.assertValues(["15%"])
    self.progress.assertValues([0.15])
    self.progressBarColor.assertValues([UIColor.ksr_dark_grey_400])
    self.projectImageUrl.assertValues(["http://wwww.cosmicsurgery.com/theproject.jpg"])
    self.projectName.assertValues(["Cosmic Surgery"])
  }
}
