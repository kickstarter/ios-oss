@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ProjectFAQsCellViewModelTests: TestCase {
  let vm: ProjectFAQsCellViewModelType = ProjectFAQsCellViewModel()

  private let faq = ProjectFAQ(
    answer: "answer 1",
    question: "question 1",
    id: 0,
    createdAt: Date(timeIntervalSince1970: 1_475_361_315).timeIntervalSince1970
  )
  private let answerLabelText = TestObserver<String, Never>()
  private let answerStackViewIsHidden = TestObserver<Bool, Never>()
  private let configureChevronImageView = TestObserver<Bool, Never>()
  private let questionLabelText = TestObserver<String, Never>()
  private let updatedLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.answerLabelText.observe(self.answerLabelText.observer)
    self.vm.outputs.answerStackViewIsHidden.observe(self.answerStackViewIsHidden.observer)
    self.vm.outputs.configureChevronImageView.observe(self.configureChevronImageView.observer)
    self.vm.outputs.questionLabelText.observe(self.questionLabelText.observer)
    self.vm.outputs.updatedLabelText.observe(self.updatedLabelText.observer)
  }

  func testOutput_AnswerLabelText() {
    self.vm.inputs.configureWith(value: (self.faq, false))

    self.answerLabelText.assertValues(["answer 1"])
  }

  func testOutput_AnswerStackViewIsHidden() {
    self.vm.inputs.configureWith(value: (self.faq, false))

    self.answerStackViewIsHidden.assertValues([true])

    self.vm.inputs.configureWith(value: (self.faq, true))

    self.answerStackViewIsHidden.assertValues([true, false])
  }

  func testOutput_ConfigureChevronImageView() {
    self.vm.inputs.configureWith(value: (self.faq, false))

    self.configureChevronImageView.assertValues([false])

    self.vm.inputs.configureWith(value: (self.faq, true))

    self.configureChevronImageView.assertValues([false, true])
  }

  func testOutput_QuestionLabelText() {
    self.vm.inputs.configureWith(value: (self.faq, false))

    self.questionLabelText.assertValues(["question 1"])
  }

  func testOutput_UpdatedLabelText() {
    self.vm.inputs.configureWith(value: (self.faq, false))

    self.updatedLabelText.assertValues(["Updated Oct 1, 2016"])
  }
}
