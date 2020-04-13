import Foundation
@testable import KsApi
import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class ProjectSummaryCarouselCellViewModelTests: TestCase {
  private let vm: ProjectSummaryCarouselCellViewModelType = ProjectSummaryCarouselCellViewModel()

  private let body = TestObserver<String, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.body.observe(self.body.observer)
  }

  func testTitle_WhatIsTheProject() {
    self.title.assertDidNotEmitValue()
    self.body.assertDidNotEmitValue()

    let item = ProjectSummaryEnvelope.ProjectSummaryItem(
      question: .whatIsTheProject,
      response: "Test copy 1"
    )

    self.vm.inputs.configure(with: item)

    self.title.assertValues(["What is this project?"])
    self.body.assertValues(["Test copy 1"])
  }

  func testTitle_WhatWillYouDoWithTheMoney() {
    self.title.assertDidNotEmitValue()
    self.body.assertDidNotEmitValue()

    let item = ProjectSummaryEnvelope.ProjectSummaryItem(
      question: .whatWillYouDoWithTheMoney,
      response: "Test copy 2"
    )

    self.vm.inputs.configure(with: item)

    self.title.assertValues(["How will the funds bring it to life?"])
    self.body.assertValues(["Test copy 2"])
  }

  func testTitle_WhoAreYou() {
    self.title.assertDidNotEmitValue()
    self.body.assertDidNotEmitValue()

    let item = ProjectSummaryEnvelope.ProjectSummaryItem(
      question: .whoAreYou,
      response: "Test copy 3"
    )

    self.vm.inputs.configure(with: item)

    self.title.assertValues(["Who is the creator?"])
    self.body.assertValues(["Test copy 3"])
  }
}
