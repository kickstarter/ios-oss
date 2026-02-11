import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectRisksDisclaimerCellViewModelInputs {
  /// Call when the UILabel  is tapped.
  func descriptionLabelTapped(url: URL)
}

public protocol ProjectRisksDisclaimerCellViewModelOutputs {
  /// Emits an `URL` when the description label is tapped.
  var notifyDelegateDescriptionLabelTapped: Signal<URL, Never> { get }
}

public protocol ProjectRisksDisclaimerCellViewModelType {
  var inputs: ProjectRisksDisclaimerCellViewModelInputs { get }
  var outputs: ProjectRisksDisclaimerCellViewModelOutputs { get }
}

public final class ProjectRisksDisclaimerCellViewModel:
  ProjectRisksDisclaimerCellViewModelType,
  ProjectRisksDisclaimerCellViewModelInputs,
  ProjectRisksDisclaimerCellViewModelOutputs {
  public init() {
    self.notifyDelegateDescriptionLabelTapped = self.descriptionLabelTappedProperty.signal
      .skipNil()
  }

  fileprivate let descriptionLabelTappedProperty = MutableProperty<URL?>(nil)
  public func descriptionLabelTapped(url: URL) {
    self.descriptionLabelTappedProperty.value = url
  }

  public let notifyDelegateDescriptionLabelTapped: Signal<URL, Never>

  public var inputs: ProjectRisksDisclaimerCellViewModelInputs { self }
  public var outputs: ProjectRisksDisclaimerCellViewModelOutputs { self }
}
