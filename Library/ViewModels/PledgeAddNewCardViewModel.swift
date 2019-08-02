import Foundation
import ReactiveSwift

public protocol PledgeAddNewCardViewModelOutputs {
  var notifyDelegateAddNewCardTapped: Signal<Void, Never> { get }
}

public protocol PledgeAddNewCardViewModelInputs {
  func addNewCardButtonTapped()
}

public protocol PledgeAddNewCardViewModelType {
  var inputs: PledgeAddNewCardViewModelInputs { get }
  var outputs: PledgeAddNewCardViewModelOutputs { get }
}

public final class PledgeAddNewCardViewModel: PledgeAddNewCardViewModelType, PledgeAddNewCardViewModelInputs,
  PledgeAddNewCardViewModelOutputs {
  public init() {
    self.notifyDelegateAddNewCardTapped = self.addNewCardButtonTappedProperty.signal
  }

  private let addNewCardButtonTappedProperty = MutableProperty(())
  public func addNewCardButtonTapped() {
    self.addNewCardButtonTappedProperty.value = ()
  }

  public let notifyDelegateAddNewCardTapped: Signal<Void, Never>

  public var inputs: PledgeAddNewCardViewModelInputs { return self }
  public var outputs: PledgeAddNewCardViewModelOutputs { return self }
}
