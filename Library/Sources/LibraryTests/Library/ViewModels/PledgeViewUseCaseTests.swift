@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeViewUseCaseTests: TestCase {
  private var useCase: ViewPledgeUseCase!

  private let goToNativePledgeViewProjectParam = TestObserver<Param, Never>()
  private let goToNativePledgeViewBackingParam = TestObserver<Param?, Never>()
  private let goToPledgeManagementPledgeView = TestObserver<String, Never>()

  private let (projectAndBackingSignal, projectAndBackingObserver) = Signal<(Project, Backing), Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = .init(with: self.projectAndBackingSignal)

    self.useCase.outputs.goToNativePledgeView.map(first)
      .observe(self.goToNativePledgeViewProjectParam.observer)
    self.useCase.outputs.goToNativePledgeView.map(second)
      .observe(self.goToNativePledgeViewBackingParam.observer)
    self.useCase.outputs.goToPledgeManagementPledgeView.observe(self.goToPledgeManagementPledgeView.observer)
  }

  func test_goToPledgeManagementPledgeView_when_isBacker() {
    var project = Project.template
    project.personalization.isBacking = .some(true)

    let backing = Backing.templateMadeWithPledgeManagment
    let expectedURL = backing.backingDetailsPageRoute

    self.projectAndBackingObserver.send(value: (project, backing))

    self.goToNativePledgeViewProjectParam.assertDidNotEmitValue()
    self.goToNativePledgeViewBackingParam.assertDidNotEmitValue()
    self.goToPledgeManagementPledgeView.assertDidNotEmitValue()

    self.useCase.inputs.goToPledgeViewTapped()

    self.goToNativePledgeViewProjectParam.assertDidNotEmitValue()
    self.goToNativePledgeViewBackingParam.assertDidNotEmitValue()
    self.goToPledgeManagementPledgeView.assertValue(expectedURL)
  }

  func test_goToNativePledgeView_when_isCreator() {
    var project = Project.template
    project.personalization.isBacking = .some(false)
    let backing = Backing.templateMadeWithPledgeManagment
    self.projectAndBackingObserver.send(value: (project, backing))

    self.goToNativePledgeViewProjectParam.assertDidNotEmitValue()
    self.goToNativePledgeViewBackingParam.assertDidNotEmitValue()
    self.goToPledgeManagementPledgeView.assertDidNotEmitValue()

    self.useCase.inputs.goToPledgeViewTapped()

    self.goToNativePledgeViewProjectParam.assertLastValue(.slug(project.slug))
    self.goToNativePledgeViewBackingParam.assertLastValue(.id(backing.id))
    self.goToPledgeManagementPledgeView.assertDidNotEmitValue()
  }
}
