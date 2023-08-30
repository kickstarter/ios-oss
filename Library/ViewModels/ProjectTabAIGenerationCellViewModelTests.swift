@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectTabAIGenerationCellViewModelTests: TestCase {
  fileprivate let vm: ProjectAIGenerationAnswerCellViewModelType =
    ProjectTabAIGenerationCellViewModel()

  fileprivate let questionLabelText = TestObserver<String, Never>()
  fileprivate let answerLabelText = TestObserver<String, Never>()

  private let questionAnswer = ("question", "answer")

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.questionLabelText.observe(self.questionLabelText.observer)
    self.vm.outputs.answerLabelText.observe(self.answerLabelText.observer)
  }

  func testOutput_QuestionLabelText() {
    self.vm.inputs.configureWith(value: self.questionAnswer)

    self.questionLabelText.assertValues(["question"])
  }

  func testOutput_AnswerLabelText() {
    self.vm.inputs.configureWith(value: self.questionAnswer)

    self.answerLabelText.assertValues(["answer"])
  }
}
