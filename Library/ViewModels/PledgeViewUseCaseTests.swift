@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeViewUseCaseTests: TestCase {
  private var useCase: PledgeViewRoutingUseCase!

  private let goToNativePledgeViewProjectParam = TestObserver<Param, Never>()
  private let goToNativePledgeViewBackingParam = TestObserver<Param?, Never>()
  private let goToPledgeManagementViewPledge = TestObserver<URL, Never>()

  private let (projectAndBackingSignal, projectAndBackingObserver) = Signal<(Project, Backing), Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = .init(with: self.projectAndBackingSignal)

    self.useCase.outputs.goToNativePledgeView.map(first)
      .observe(self.goToNativePledgeViewProjectParam.observer)
    self.useCase.outputs.goToNativePledgeView.map(second)
      .observe(self.goToNativePledgeViewBackingParam.observer)
    self.useCase.outputs.goToPledgeManagementPledgeView.observe(self.goToPledgeManagementViewPledge.observer)
  }

  func test_onStandardPledge() {
    let project = Project.template
    let backing = Backing.template

    self.projectAndBackingObserver.send(value: (project, backing))

    self.goToNativePledgeViewProjectParam.assertDidNotEmitValue()
    self.goToNativePledgeViewBackingParam.assertDidNotEmitValue()
    self.goToPledgeManagementViewPledge.assertDidNotEmitValue()

    self.useCase.inputs.goToPledgeViewTapped()

    self.goToNativePledgeViewProjectParam.assertLastValue(.slug(project.slug))
    self.goToNativePledgeViewBackingParam.assertLastValue(.id(backing.id))
    self.goToPledgeManagementViewPledge.assertDidNotEmitValue()
  }

  func test_onPledgeManagementPledge() {
    let project = Project.template
    let backing = Backing.templateMadeWithPledgeManagment
    let expectedURL = URL(string: backing.backingDetailsPageRoute)!

    self.projectAndBackingObserver.send(value: (project, backing))

    self.goToNativePledgeViewProjectParam.assertDidNotEmitValue()
    self.goToNativePledgeViewBackingParam.assertDidNotEmitValue()
    self.goToPledgeManagementViewPledge.assertDidNotEmitValue()

    self.useCase.inputs.goToPledgeViewTapped()

    self.goToNativePledgeViewProjectParam.assertDidNotEmitValue()
    self.goToNativePledgeViewBackingParam.assertDidNotEmitValue()
    self.goToPledgeManagementViewPledge.assertValue(expectedURL)
  }
}
