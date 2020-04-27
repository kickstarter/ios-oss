@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionHeaderViewModelTests: TestCase {
  private let stepLabelIsHidden = TestObserver<Bool, Never>()
  private let stepLabelText = TestObserver<String, Never>()
  private let subtitleLabelText = TestObserver<String, Never>()
  private let titleLabelText = TestObserver<String, Never>()

  private let vm: CategorySelectionHeaderViewModelType
    = CategorySelectionHeaderViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.stepLabelIsHidden.observe(self.stepLabelIsHidden.observer)
    self.vm.outputs.stepLabelText.observe(self.stepLabelText.observer)
    self.vm.outputs.subtitleLabelText.observe(self.subtitleLabelText.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
  }

  func testLabels_CategorySelectionContext() {
    self.vm.inputs.configure(with: .categorySelection)

    self.stepLabelText.assertValue("Step 1 of 2")
    self.subtitleLabelText.assertValue("Select up to five from the options below.")
    self.titleLabelText.assertValue("Which categories interest you?")
    self.stepLabelIsHidden.assertValues([false])
  }

  func testLabels_CuratedProjectsContext_Discovery() {
    self.vm.inputs.configure(with: .curatedProjects(.discovery))

    self.stepLabelText.assertDidNotEmitValue()
    self.subtitleLabelText.assertDidNotEmitValue()
    self.titleLabelText.assertValue("Check out these handpicked projects just for you.")
    self.stepLabelIsHidden.assertValues([true])
  }

  func testLabels_CuratedProjectsContext_Onboarding() {
    self.vm.inputs.configure(with: .curatedProjects(.onboarding))

    self.stepLabelText.assertValue("Step 2 of 2")
    self.subtitleLabelText.assertDidNotEmitValue()
    self.titleLabelText.assertValue("Check out these handpicked projects just for you.")
    self.stepLabelIsHidden.assertValues([false])
  }
}
