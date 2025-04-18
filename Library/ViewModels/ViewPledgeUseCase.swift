import Foundation
import KsApi
import ReactiveSwift

public protocol ViewPledgeUseCaseInputs {
  func goToPledgeViewTapped()
}

public protocol ViewPledgeUseCaseOutputs {
  var goToNativePledgeView: Signal<ManagePledgeViewParamConfigData, Never> { get }
  var goToPledgeManagementPledgeView: Signal<URL, Never> { get }
}

public protocol ViewPledgeUseCaseType {
  var inputs: ViewPledgeUseCaseInputs { get }
  var outputs: ViewPledgeUseCaseOutputs { get }
}

/// Determines the correct destination when viewing a pledge—either routing to the pledge
/// management web view or the native pledge view—based on the backing, order state, and
/// whether the pledge follows the net new backer flow.
/// Triggered when the user taps to manage their pledge or go to backing details.
public final class ViewPledgeUseCase: ViewPledgeUseCaseType,
  ViewPledgeUseCaseInputs,
  ViewPledgeUseCaseOutputs {
  public init(with projectAndBacking: Signal<(Project, Backing), Never>) {
    let goToPledgeViewSignal = self.goToPledgeViewTappedProperty.signal

    let shouldGoToPledgeManagementPledgeView = projectAndBacking
      .takeWhen(goToPledgeViewSignal)
      .map { project, backing -> Bool in
        guard featureNetNewBackersWebViewEnabled() else { return false }

        guard let order = backing.order, let isBacking = project.personalization.isBacking,
              isBacking else { return false }

        return order.checkoutState == .complete
      }

    self.goToPledgeManagementPledgeView = projectAndBacking
      .takeWhen(shouldGoToPledgeManagementPledgeView.filter { $0 })
      .compactMap { _, backing in
        URL(string: backing.backingDetailsPageRoute)
      }

    self.goToNativePledgeView = projectAndBacking
      .takeWhen(shouldGoToPledgeManagementPledgeView.filter { !$0 })
      .map { project, backing in
        (projectParam: Param.slug(project.slug), backingParam: Param.id(backing.id))
      }
  }

  public let goToNativePledgeView: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToPledgeManagementPledgeView: Signal<URL, Never>

  public var inputs: ViewPledgeUseCaseInputs { return self }
  public var outputs: ViewPledgeUseCaseOutputs { return self }

  private let goToPledgeViewTappedProperty = MutableProperty(())
  public func goToPledgeViewTapped() {
    self.goToPledgeViewTappedProperty.value = ()
  }
}
