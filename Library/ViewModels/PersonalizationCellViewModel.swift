import Foundation
import ReactiveSwift

public protocol PersonalizationCellViewModelInputs {
  func cellTapped()
  func dismissButtonTapped()
}

public protocol PersonalizationCellViewModelOutputs {
  var notifyDelegateDismissButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateViewTapped: Signal<Void, Never> { get }
}

public protocol PersonalizationCellViewModelType {
  var inputs: PersonalizationCellViewModelInputs { get }
  var outputs: PersonalizationCellViewModelOutputs { get }
}

public final class PersonalizationCellViewModel: PersonalizationCellViewModelType,
  PersonalizationCellViewModelInputs, PersonalizationCellViewModelOutputs {
  public init() {
    self.notifyDelegateDismissButtonTapped = self.dismissButtonTappedProperty.signal
    self.notifyDelegateViewTapped = self.cellTappedProperty.signal
  }

  private let cellTappedProperty = MutableProperty(())
  public func cellTapped() {
    self.cellTappedProperty.value = ()
  }

  private let dismissButtonTappedProperty = MutableProperty(())
  public func dismissButtonTapped() {
    self.dismissButtonTappedProperty.value = ()
  }

  public let notifyDelegateDismissButtonTapped: Signal<Void, Never>
  public let notifyDelegateViewTapped: Signal<Void, Never>

  public var inputs: PersonalizationCellViewModelInputs { return self }
  public var outputs: PersonalizationCellViewModelOutputs { return self }
}
