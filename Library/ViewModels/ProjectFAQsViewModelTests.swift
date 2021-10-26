@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ProjectFAQsViewModelTests: TestCase {
  private let vm: ProjectFAQsViewModelType = ProjectFAQsViewModel()

  private let loadFAQsProjectFAQs = TestObserver<[ProjectFAQ], Never>()
  private let loadFAQsIsExpandedStates = TestObserver<[Bool], Never>()
  private let presentMessageDialog = TestObserver<Project, Never>()
  private let updateDataSourceProjectFAQs = TestObserver<[ProjectFAQ], Never>()
  private let updateDataSourceIsExpandedStates = TestObserver<[Bool], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadFAQs.map(first).observe(self.loadFAQsProjectFAQs.observer)
    self.vm.outputs.loadFAQs.map(second).observe(self.loadFAQsIsExpandedStates.observer)
    self.vm.outputs.presentMessageDialog.observe(self.presentMessageDialog.observer)
    self.vm.outputs.updateDataSource.map(first).observe(self.updateDataSourceProjectFAQs.observer)
    self.vm.outputs.updateDataSource.map(second).observe(self.updateDataSourceIsExpandedStates.observer)
  }

  func testOutput_loadFAQsProject() {
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.vm.inputs.configureWith(project: project)

    self.loadFAQsProjectFAQs.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.loadFAQsProjectFAQs.assertDidEmitValue()
  }

  func testOutput_loadFAQsIsExpandedStates() {
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.vm.inputs.configureWith(project: project)

    self.loadFAQsIsExpandedStates.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.loadFAQsIsExpandedStates.assertValues([[false, false, false, false]])
  }

  func testOutput_PresentMessageDialog() {
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.vm.inputs.configureWith(project: project)

    self.presentMessageDialog.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.presentMessageDialog.assertDidNotEmitValue()

    self.vm.inputs.askAQuestionCellTapped()

    self.presentMessageDialog.assertValues([project])
  }

  func testOutput_updateDataSourceProject() {
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.vm.inputs.configureWith(project: project)

    self.updateDataSourceProjectFAQs.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.updateDataSourceProjectFAQs.assertDidNotEmitValue()

    self.vm.inputs.didSelectRowAt(row: 0, values: [true, false, false, false])

    self.loadFAQsProjectFAQs.assertDidEmitValue()
  }

  func testOutput_updateDataSourceIsExpandedStates() {
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.vm.inputs.configureWith(project: project)

    self.updateDataSourceIsExpandedStates.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.updateDataSourceIsExpandedStates.assertDidNotEmitValue()

    self.vm.inputs.didSelectRowAt(row: 0, values: [true, false, false, false])

    self.updateDataSourceIsExpandedStates.assertValues([[false, false, false, false]])

    self.vm.inputs.didSelectRowAt(row: 2, values: [true, false, true, false])

    self.updateDataSourceIsExpandedStates
      .assertValues([[false, false, false, false], [true, false, false, false]])
  }
}
