import Foundation
import KsApi
import ReactiveSwift

public protocol PledgeViewUseCaseInputs {
  func goToPledgeViewTapped()
}

public protocol PledgeViewUseCaseOutputs {
  var goToNativePledgeView: Signal<ManagePledgeViewParamConfigData, Never> { get }
  var goToPledgeManagementViewPledge: Signal<URL, Never> { get }
}

public protocol PledgeViewUseCaseType {
  var inputs: PledgeViewUseCaseInputs { get }
  var outputs: PledgeViewUseCaseOutputs { get }
}

public final class PledgeViewUseCase: PledgeViewUseCaseType, PledgeViewUseCaseInputs,
  PledgeViewUseCaseOutputs {
  public init(with projectAndBacking: Signal<(Project, Backing), Never>) {
    let goToPledgeViewSignal = self.goToPledgeViewTappedProperty.signal

    let shouldGoToPMPledgeView = projectAndBacking
      .takeWhen(goToPledgeViewSignal)
      .map { _, backing -> Bool in
        guard let order = backing.order else { return false }

        return order.checkoutState == .complete
      }

    self.goToPledgeManagementViewPledge = projectAndBacking
      .takeWhen(shouldGoToPMPledgeView.filter { $0 })
      .compactMap { _, backing in
        URL(string: backing.backingDetailsPageRoute)
      }

    self.goToNativePledgeView = projectAndBacking
      .takeWhen(shouldGoToPMPledgeView.filter { !$0 })
      .map { project, backing in
        (projectParam: Param.slug(project.slug), backingParam: Param.id(backing.id))
      }
  }

  public let goToNativePledgeView: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToPledgeManagementViewPledge: Signal<URL, Never>

  public var inputs: PledgeViewUseCaseInputs { return self }
  public var outputs: PledgeViewUseCaseOutputs { return self }

  private let goToPledgeViewTappedProperty = MutableProperty(())
  public func goToPledgeViewTapped() {
    self.goToPledgeViewTappedProperty.value = ()
  }
}
