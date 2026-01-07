@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardTrackingActivitiesCellViewModelTest: TestCase {
  private let vm: RewardTrackingActivitiesCellViewModelType = RewardTrackingActivitiesCellViewModel()

  private var projectName = TestObserver<String, Never>()
  private var projectImageURL = TestObserver<URL, Never>()

  private let testTrackingNumber = "1234567890"
  private let testURL = URL(string: "http://ksr.com")!

  override func setUp() {
    super.setUp()

    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.projectImageURL.observe(self.projectImageURL.observer)
  }

  func testViewModel() throws {
    let project = Project.template

    let projectImageURL = try XCTUnwrap(
      URL(string: project.photo.full),
      "projectImageURL could not be unwrapped"
    )

    self.vm.inputs.configure(with: project)

    self.projectName.assertLastValue(project.name)
    self.projectImageURL.assertLastValue(projectImageURL)
  }
}
