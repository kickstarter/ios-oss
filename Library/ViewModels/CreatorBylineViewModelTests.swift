@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CreatorBylineViewModelTests: TestCase {
  internal let vm: CreatorBylineViewModelType = CreatorBylineViewModel()

  private let creatorImageUrl = TestObserver<String?, Never>()
  private let creatorLabelText = TestObserver<String, Never>()
  private let creatorStatsText = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.creatorImageUrl.map { $0?.absoluteString }.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorLabelText.observe(self.creatorLabelText.observer)
    self.vm.outputs.creatorStatsText.observe(self.creatorStatsText.observer)
  }

  func testCreatorByline() {
    let creatorDetails = ProjectCreatorDetailsEnvelope.template
    let project = .template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.creator.name .~ "Creator Blob"
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ "hello.jpg"

    self.vm.inputs.configureWith(project: project, creatorDetails: creatorDetails)
    self.creatorImageUrl.assertValues(["hello.jpg"])
    self.creatorLabelText.assertValues(["by Creator Blob"])
    self.creatorStatsText.assertValues(["2 created • 10 backed"])
  }
}
